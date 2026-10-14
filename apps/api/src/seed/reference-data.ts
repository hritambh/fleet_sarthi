import { trackFor } from '@taxcy/domain';
import type { Db } from '../platform/prisma.service.js';
import { newId } from '../platform/ids.js';
import { CAB_MODELS } from './cab-models.js';

/**
 * Reference data every deployment needs, as opposed to the demo fleet: the cab
 * models the add-vehicle dropdowns lead with, each with the fuel baseline a new
 * vehicle of that model starts from.
 *
 * Idempotent and safe to run on every start — a model already there is left
 * alone, so a baseline someone has since tuned survives, and new entries in
 * [CAB_MODELS] reach a database seeded by an earlier release. Returns how many
 * it added.
 */
/** make and model as one comparable key; no name contains a tab. */
const key = (m: { make: string; model: string }): string => `${m.make}	${m.model}`;

export async function loadReferenceData(db: Db): Promise<number> {
  return db.system(async (tx) => {
    // One read for the lot: this runs on every cold start, so 41 round trips to
    // a remote database would be paid for on each of them.
    const present = new Set(
      (
        await tx.vehicleModel.findMany({
          where: { orgId: null },
          select: { make: true, model: true },
        })
      ).map((row) => key(row)),
    );
    let added = 0;
    for (const m of CAB_MODELS) {
      if (present.has(key(m))) continue;
      const id = newId();
      await tx.vehicleModel.create({
        data: { id, make: m.make, model: m.model, fuelType: m.fuelType },
      });
      await tx.fuelBaselineDefault.create({
        data: {
          id: newId(),
          vehicleModelId: id,
          track: trackFor(m.fuelType),
          meanValue: m.mean,
          stdValue: m.std,
        },
      });
      added += 1;
    }
    return added;
  });
}
