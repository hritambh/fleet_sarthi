import { DeleteObjectCommand } from '@aws-sdk/client-s3';
import { Prisma } from '@taxcy/db';
import { istBusinessDate } from '@taxcy/domain';
import { Db } from '../platform/prisma.service.js';
import { S3Service } from '../platform/s3.service.js';
import { DEMO_FLEETS, demoOrgIds, runSeed, type SeedContext } from './seed.js';

/**
 * Every org-scoped table, children before parents (the foreign keys between
 * them have no cycles), so the demo fleets' rows can be deleted in one pass.
 * A table added to the schema with an org_id belongs here too; the refresh
 * test fails on a leftover row.
 */
const WIPE_ORDER = [
  'settlement_lines',
  'settlements',
  'alerts',
  'review_items',
  'idempotency_keys',
  'outbox',
  'trip_distance_checks',
  'gps_points',
  'trip_collections',
  'trip_charges',
  'trip_events',
  'trip_cancellation_requests',
  'fuel_fills',
  'fuel_cycles',
  'vehicle_fuel_baselines',
  'odometer_readings',
  'trips',
  'customers',
  'document_files',
  'documents',
  'vehicle_drivers',
  'drivers',
  'vehicles',
  'vehicle_models',
  'fuel_baseline_defaults',
  'ocr_results',
  'media_objects',
  'refresh_tokens',
  'memberships',
  'org_settings',
] as const;

/**
 * Rebuilds the demo as of now: deletes the two demo fleets (Sharma Travels and
 * Patil Cabs, found by name and owner phone, so no other fleet is touched)
 * with all their records and photos, then seeds them again. The demo people's
 * accounts stay; their sessions in those fleets end, so they sign in again.
 * Used by the daily `demo.refresh` job and `bun run db:seed:refresh`.
 */
export async function refreshDemo(ctx: SeedContext): Promise<void> {
  const orgIds = await demoOrgIds(ctx.get(Db));
  if (orgIds.length) await wipeOrgs(ctx, orgIds);
  await runSeed(ctx);
}

/**
 * Deletes [orgIds] with every row in them (one transaction, children first)
 * and then their photos. Only for the demo fleets: callers pass ids from
 * demoOrgIds.
 */
export async function wipeOrgs(ctx: SeedContext, orgIds: string[]): Promise<void> {
  const db = ctx.get(Db);
  const photos = await db.system((tx) =>
    tx.mediaObject.findMany({
      where: { orgId: { in: orgIds } },
      select: { storageKey: true },
    }),
  );
  await db.system(async (tx) => {
    for (const table of WIPE_ORDER) {
      await tx.$executeRaw`DELETE FROM ${Prisma.raw(`"${table}"`)} WHERE org_id = ANY(${orgIds}::uuid[])`;
    }
    await tx.$executeRaw`DELETE FROM organizations WHERE id = ANY(${orgIds}::uuid[])`;
  });
  await deletePhotos(
    ctx.get(S3Service),
    photos.map((p) => p.storageKey),
  );
  process.stdout.write(
    `Deleted the demo fleets (${String(orgIds.length)}) and ${String(photos.length)} photos.\n`,
  );
}

/**
 * Removes the old demo photos from the bucket after the rows are gone. One at a
 * time (Backblaze B2 refuses the bulk delete's checksum), a few in parallel;
 * a photo that fails to delete only wastes a little storage, so it's logged.
 */
async function deletePhotos(s3: S3Service, keys: readonly string[]): Promise<void> {
  const queue = [...keys];
  let failed = 0;
  const worker = async () => {
    for (let key = queue.shift(); key !== undefined; key = queue.shift()) {
      try {
        await s3.client.send(new DeleteObjectCommand({ Bucket: s3.bucket, Key: key }));
      } catch {
        failed += 1;
      }
    }
  };
  await Promise.all(Array.from({ length: 8 }, worker));
  if (failed) process.stdout.write(`Could not delete ${String(failed)} old demo photos.\n`);
}

/**
 * Rebuilds the demo unless it was already seeded, completely, today (IST), so
 * "today", "this evening" and "tomorrow" in the demo always mean today. Seeds
 * it when missing. Returns whether it rebuilt.
 */
export async function refreshDemoIfStale(ctx: SeedContext, now = new Date()): Promise<boolean> {
  const db = ctx.get(Db);
  // Sharma Travels is seeded first (its age is the demo's) and Patil Cabs last:
  // without Patil Cabs an earlier seed stopped partway, so rebuild.
  const [sharma] = await demoOrgIds(db, [DEMO_FLEETS[0]]);
  const [patil] = await demoOrgIds(db, [DEMO_FLEETS[1]]);
  if (sharma && patil) {
    const org = await db.system((tx) =>
      tx.organization.findUniqueOrThrow({ where: { id: sharma }, select: { createdAt: true } }),
    );
    if (istBusinessDate(org.createdAt) === istBusinessDate(now)) return false;
  }
  await refreshDemo(ctx);
  return true;
}
