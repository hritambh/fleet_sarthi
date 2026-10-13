import type { Session } from '@taxcy/contracts';
import { randomUUID } from 'node:crypto';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import { bearer, ownerSession, startHarness, type Harness } from './harness.js';

let h: Harness;
let owner: Session;
const vehicleA = randomUUID();
const vehicleB = randomUUID();
const driver = randomUUID();

async function alert(
  title: string,
  fields: { status: string; severity: 'info' | 'warning' | 'critical'; kind: string } & {
    vehicleId?: string;
    driverId?: string;
  },
) {
  await h.owner.alert.create({
    data: {
      id: randomUUID(),
      orgId: owner.activeOrgId ?? '',
      title,
      explanation: title,
      subjectType: 'vehicle',
      subjectId: randomUUID(),
      dedupeKey: `test:${randomUUID()}`,
      ...fields,
    },
  });
}

async function titles(query: Record<string, string>): Promise<string[]> {
  const res = await request(h.http)
    .get('/v1/alerts')
    .query(query)
    .set(...bearer(owner))
    .expect(200);
  return (res.body as { title: string }[]).map((a) => a.title).sort();
}

beforeAll(async () => {
  h = await startHarness();
  owner = await ownerSession(h, 'fleet', 'Filter Travels');
  await alert('A fuel open critical', {
    status: 'open',
    severity: 'critical',
    kind: 'fuel_efficiency_low',
    vehicleId: vehicleA,
  });
  await alert('B doc acknowledged warning', {
    status: 'acknowledged',
    severity: 'warning',
    kind: 'document_expiring',
    vehicleId: vehicleB,
  });
  await alert('C doc resolved info', {
    status: 'resolved',
    severity: 'info',
    kind: 'document_expired',
    driverId: driver,
  });
});

afterAll(async () => {
  // The database is shared with the other test files (run one after another):
  // leave no open alerts behind for them to count.
  await h.owner.alert.deleteMany({ where: { orgId: owner.activeOrgId ?? '' } });
  await h.close();
});

describe('GET /alerts filters', () => {
  it('takes one value, as before', async () => {
    expect(await titles({ status: 'open' })).toEqual(['A fuel open critical']);
  });

  it('ORs a list within one filter and ANDs filters', async () => {
    expect(await titles({ status: 'open,acknowledged' })).toEqual([
      'A fuel open critical',
      'B doc acknowledged warning',
    ]);
    expect(await titles({ status: 'open,acknowledged', severity: 'warning' })).toEqual([
      'B doc acknowledged warning',
    ]);
    expect(await titles({ kind: 'document_expiring,document_expired' })).toEqual([
      'B doc acknowledged warning',
      'C doc resolved info',
    ]);
  });

  it('matches alerts about any chosen vehicle or driver', async () => {
    expect(await titles({ vehicleId: vehicleA, driverId: driver })).toEqual([
      'A fuel open critical',
      'C doc resolved info',
    ]);
  });

  it('rejects an unknown value', async () => {
    await request(h.http)
      .get('/v1/alerts')
      .query({ status: 'open,bogus' })
      .set(...bearer(owner))
      .expect(400);
  });
});
