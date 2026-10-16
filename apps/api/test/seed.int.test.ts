import type { Session } from '@taxcy/contracts';
import { randomUUID } from 'node:crypto';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { refreshDemo, refreshDemoIfStale } from '../src/seed/demo-refresh.js';
import { DEMO_PASSWORD, demoOrgIds, runSeed } from '../src/seed/seed.js';
import { Db } from '../src/platform/prisma.service.js';
import { ownerSession } from './harness.js';
import { startHarness, type Harness } from './harness.js';

let h: Harness;

beforeAll(async () => {
  h = await startHarness();
  await runSeed(h.app);
}, 600_000);

afterAll(async () => {
  await h.close();
});

/** The seeded org, found by its owner's phone: other test files also use the name. */
const demoOrg = () =>
  h.owner.organization.findFirstOrThrow({
    where: {
      name: 'Sharma Travels',
      memberships: { some: { user: { phoneE164: '+919000000001' }, roles: { has: 'owner' } } },
    },
  });

describe('demo seed', () => {
  it('creates the org, people and vehicles', async () => {
    const org = await demoOrg();
    expect(await h.owner.vehicle.count({ where: { orgId: org.id } })).toBe(3);
    expect(await h.owner.driver.count({ where: { orgId: org.id } })).toBe(3);
    expect(await h.owner.membership.count({ where: { orgId: org.id } })).toBe(5);
  });

  it('lets every demo person sign in with the demo password', async () => {
    for (const phone of ['+919000000001', '+919000000002', '+919000000012']) {
      const res = await request(h.http)
        .post('/v1/auth/password/login')
        .send({ phone, password: DEMO_PASSWORD, deviceId: randomUUID(), platform: 'web' })
        .expect(200);
      expect((res.body as Session).memberships.map((m) => m.orgName)).toContain('Sharma Travels');
    }
  });

  it('gives Anil and Suresh a fleet each and a driving job in the other', async () => {
    const login = async (phone: string) =>
      (
        await request(h.http)
          .post('/v1/auth/password/login')
          .send({ phone, password: DEMO_PASSWORD, deviceId: randomUUID(), platform: 'web' })
          .expect(200)
      ).body as Session;
    const roles = (s: Session) => s.memberships.map((m) => `${m.orgName}: ${m.roles.join('+')}`);

    const anil = await login('+919000000001');
    expect(roles(anil)).toEqual(['Sharma Travels: owner', 'Patil Cabs: driver']);
    const suresh = await login('+919000000012');
    expect(roles(suresh)).toEqual(['Sharma Travels: driver', 'Patil Cabs: owner']);
    // Each signs in to the fleet they own.
    const orgName = (s: Session) => s.memberships.find((m) => m.orgId === s.activeOrgId)?.orgName;
    expect(orgName(anil)).toBe('Sharma Travels');
    expect(orgName(suresh)).toBe('Patil Cabs');

    // Anil has a trip to drive for Patil Cabs.
    const driving = await request(h.http)
      .post('/v1/auth/switch-org')
      .set('Authorization', `Bearer ${anil.accessToken}`)
      .send({
        orgId: anil.memberships.find((m) => m.orgName === 'Patil Cabs')?.orgId,
        refreshToken: anil.refreshToken,
      })
      .expect(200);
    const trips = await request(h.http)
      .get('/v1/me/trips')
      .set('Authorization', `Bearer ${(driving.body as Session).accessToken}`)
      .expect(200);
    expect(trips.body).toHaveLength(1);
  });

  it('produces the alerts the getting-started guide promises', async () => {
    // Only the demo fleet's: other test files share this database and raise
    // alerts of their own (e.g. fuel alerts in fuel.int.test.ts).
    const org = await demoOrg();
    const open = await h.owner.alert.findMany({ where: { status: 'open', orgId: org.id } });
    const titles = open.map((a) => `${a.kind}: ${a.title}`);
    expect(titles).toEqual(
      expect.arrayContaining([
        expect.stringMatching(
          /^fuel_efficiency_low: MH12CD5678 \(Dzire, CNG\) used more fuel than usual$/,
        ),
        expect.stringMatching(
          /^odo_gps_mismatch: Trip on .* \(.*MH12AB1234\) shows more km on the odometer than the GPS route$/,
        ),
        expect.stringMatching(/^document_expiring: Insurance for MH12CD5678 expires in 5 days$/),
        // Tomorrow's Goa booking has no vehicle or driver yet.
        'trip_unassigned: Trip Pune Station → Goa (Panaji) has no vehicle or driver yet',
      ]),
    );
    expect(open.filter((a) => a.kind === 'fuel_efficiency_low')).toHaveLength(1);
  });

  it('has an OCR mismatch waiting in the review queue', async () => {
    const items = await h.owner.reviewItem.findMany({ where: { status: 'open' } });
    expect(items.map((i) => i.kind)).toContain('ocr_mismatch_odometer');
  });

  it('has trips in every state and settles all but the last two days', async () => {
    const byStatus = await h.owner.trip.groupBy({ by: ['status'], _count: { _all: true } });
    const statuses = Object.fromEntries(byStatus.map((s) => [s.status, s._count._all]));
    expect(Object.keys(statuses).sort()).toEqual([
      'assigned',
      'cancelled',
      'created',
      'ended',
      'settled',
      'started',
    ]);
    expect(statuses['settled']).toBeGreaterThan(50);
    expect(await h.owner.settlement.count({ where: { status: 'settled' } })).toBeGreaterThan(60);
  });

  it('is safe to run twice', async () => {
    await runSeed(h.app);
    expect(
      await h.owner.organization.count({
        where: { memberships: { some: { user: { phoneE164: '+919000000001' } } } },
      }),
    ).toBe(2);
    expect(await h.owner.organization.count({ where: { name: 'Patil Cabs' } })).toBe(1);
  });
});

describe('demo refresh', () => {
  /** Rows left in any org-scoped table for these orgs. */
  const leftovers = async (orgIds: string[]) => {
    const tables = await h.owner.$queryRaw<{ table_name: string }[]>`
      SELECT table_name FROM information_schema.columns
      WHERE table_schema = 'public' AND column_name = 'org_id'
        AND table_name NOT LIKE 'gps_points_%'`;
    const counts: Record<string, number> = {};
    for (const { table_name } of tables) {
      const [row] = await h.owner.$queryRawUnsafe<{ n: bigint }[]>(
        `SELECT count(*) AS n FROM "${table_name}" WHERE org_id = ANY($1::uuid[])`,
        orgIds,
      );
      if (row && row.n > 0n) counts[table_name] = Number(row.n);
    }
    return counts;
  };

  it('rebuilds the two demo fleets for today and leaves every other fleet alone', async () => {
    const db = h.app.get(Db);
    const before = await demoOrgIds(db);
    expect(before).toHaveLength(2);
    // A real fleet that shares the demo's name, and someone trying the demo.
    const other = await ownerSession(h, 'fleet', 'Sharma Travels');
    const otherOrg = other.activeOrgId ?? '';
    const sharma = await demoOrg();
    await h.owner.trip.updateMany({
      where: { orgId: sharma.id, status: 'started' },
      data: { status: 'ended', endedAt: new Date() },
    });

    await refreshDemo(h.app);

    const after = await demoOrgIds(db);
    expect(after).toHaveLength(2);
    expect(after.some((id) => before.includes(id))).toBe(false);
    expect(await leftovers(before)).toEqual({});
    expect(await h.owner.organization.count({ where: { id: { in: before } } })).toBe(0);
    // The other fleet named Sharma Travels is still there.
    expect(await h.owner.organization.count({ where: { id: otherOrg } })).toBe(1);
    // Back to the picture the demo promises: Suresh on the road again.
    const fresh = await demoOrg();
    expect(await h.owner.trip.count({ where: { orgId: fresh.id, status: 'started' } })).toBe(1);
    // Same people, same password.
    await request(h.http)
      .post('/v1/auth/password/login')
      .send({
        phone: '+919000000001',
        password: DEMO_PASSWORD,
        deviceId: randomUUID(),
        platform: 'web',
      })
      .expect(200);
  }, 600_000);

  it('only rebuilds when the demo was seeded on an earlier day', async () => {
    const ids = await demoOrgIds(h.app.get(Db));
    expect(await refreshDemoIfStale(h.app)).toBe(false);
    expect(await demoOrgIds(h.app.get(Db))).toEqual(ids);
    const tomorrow = new Date(Date.now() + 86_400_000);
    expect(await refreshDemoIfStale(h.app, tomorrow)).toBe(true);
    expect((await demoOrgIds(h.app.get(Db))).some((id) => ids.includes(id))).toBe(false);
  }, 600_000);
});
