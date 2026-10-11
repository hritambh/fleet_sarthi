import type { Session } from '@taxcy/contracts';
import { istBusinessDate } from '@taxcy/domain';
import { randomUUID } from 'node:crypto';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  bearer,
  createVehicle as addVehicle,
  driverSession,
  key,
  ownerSession,
  randomPhone,
  runSchedule,
  schedule,
  startHarness,
  type Harness,
} from './harness.js';

let h: Harness;
let owner: Session;

const addDays = (days: number) =>
  new Date(Date.parse(`${istBusinessDate(new Date())}T00:00:00Z`) + days * 86_400_000)
    .toISOString()
    .slice(0, 10);

async function createVehicle(session: Session, registrationNo: string, fuelType = 'diesel') {
  const res = await request(h.http)
    .post('/v1/vehicles')
    .set(...bearer(session))
    .send({
      registrationNo,
      make: 'Toyota',
      model: 'Innova Crysta',
      fuelType,
      lastOdometerKm: 48_000,
    })
    .expect(201);
  return res.body as { id: string; registrationNo: string };
}

beforeAll(async () => {
  h = await startHarness();
  owner = await ownerSession(h, 'fleet', 'Sharma Travels');
});

afterAll(async () => {
  await h.close();
});

describe('vehicles', () => {
  it('normalises the registration number and rejects duplicates', async () => {
    const vehicle = await createVehicle(owner, 'mh 12-ab 1234');
    expect(vehicle.registrationNo).toBe('MH12AB1234');
    const dup = await request(h.http)
      .post('/v1/vehicles')
      .set(...bearer(owner))
      .send({ registrationNo: 'MH12AB1234', make: 'X', model: 'Y', fuelType: 'cng' })
      .expect(409);
    expect(dup.body).toMatchObject({ error: { code: 'CONFLICT' } });
  });

  it('updates and lists', async () => {
    const vehicle = await createVehicle(owner, 'MH12AB5678');
    await request(h.http)
      .patch(`/v1/vehicles/${vehicle.id}`)
      .set(...bearer(owner))
      .send({ status: 'inactive' })
      .expect(200);
    const active = await request(h.http)
      .get('/v1/vehicles?status=active')
      .set(...bearer(owner))
      .expect(200);
    expect((active.body as { id: string }[]).map((v) => v.id)).not.toContain(vehicle.id);
  });

  it('is invisible to another org', async () => {
    const vehicle = await createVehicle(owner, 'MH12ZZ0001');
    const other = await ownerSession(h, 'fleet', 'Other Fleet');
    await request(h.http)
      .get(`/v1/vehicles/${vehicle.id}`)
      .set(...bearer(other))
      .expect(404);
    const list = await request(h.http)
      .get('/v1/vehicles')
      .set(...bearer(other))
      .expect(200);
    expect(list.body).toEqual([]);
  });
});

describe('drivers', () => {
  it('invites a driver, who becomes active on first sign-in and gets a driver-scoped session', async () => {
    const { session, driverId } = await driverSession(h, owner, 'Suresh Patil');
    expect(session.activeOrgId).toBe(owner.activeOrgId);
    expect(session.memberships[0]?.roles).toEqual(['driver']);
    const driver = await request(h.http)
      .get(`/v1/drivers/${driverId}`)
      .set(...bearer(owner))
      .expect(200);
    expect(driver.body).toMatchObject({
      name: 'Suresh Patil',
      membershipStatus: 'active',
      payRule: null,
    });
  });

  it('does not let drivers manage the fleet', async () => {
    const { session } = await driverSession(h, owner);
    const res = await request(h.http)
      .post('/v1/vehicles')
      .set(...bearer(session))
      .send({ registrationNo: 'MH12DR0001', make: 'X', model: 'Y', fuelType: 'cng' })
      .expect(403);
    expect(res.body).toMatchObject({ error: { code: 'FORBIDDEN_ROLE' } });
    await request(h.http)
      .get('/v1/vehicles')
      .set(...bearer(session))
      .expect(200);
  });

  it('rejects inviting the same driver twice', async () => {
    const phone = '+919811111111';
    await request(h.http)
      .post('/v1/drivers')
      .set(...bearer(owner))
      .send({ name: 'A', phone })
      .expect(201);
    await request(h.http)
      .post('/v1/drivers')
      .set(...bearer(owner))
      .send({ name: 'A', phone })
      .expect(409);
  });

  it('lets the owner override a driver pay rule, and validates it', async () => {
    const { driverId } = await driverSession(h, owner);
    const rule = { kind: 'per_trip', amountPaise: 30_000, allowanceToDriver: true };
    const res = await request(h.http)
      .put(`/v1/drivers/${driverId}/pay-rule`)
      .set(...bearer(owner))
      .send({ payRule: rule })
      .expect(200);
    expect(res.body).toMatchObject({ payRule: rule });
    await request(h.http)
      .put(`/v1/drivers/${driverId}/pay-rule`)
      .set(...bearer(owner))
      .send({ payRule: { kind: 'per_trip', allowanceToDriver: true } })
      .expect(400);
    const cleared = await request(h.http)
      .put(`/v1/drivers/${driverId}/pay-rule`)
      .set(...bearer(owner))
      .send({ payRule: null })
      .expect(200);
    expect(cleared.body).toMatchObject({ payRule: null });
  });
});

describe('drivers and vehicles (many to many)', () => {
  const unlinked = { linkAll: false };
  interface Linked {
    id: string;
    drivers: { id: string; name: string }[];
  }

  function trip(vehicleId: string, driverId: string, session = owner) {
    return request(h.http)
      .post('/v1/trips')
      .set(...bearer(session))
      .send({
        tripType: 'one_way',
        customer: { name: 'Anita Desai', phone: '+919822222222' },
        from: { text: 'Pune Station' },
        to: { text: 'Mumbai Airport T2' },
        ...schedule(),
        quotedFarePaise: 350_000,
        vehicleId,
        driverId,
      });
  }

  function setDrivers(vehicleId: string, driverIds: string[]) {
    return request(h.http)
      .put(`/v1/vehicles/${vehicleId}/drivers`)
      .set(...bearer(owner))
      .send({ driverIds });
  }

  it('links a vehicle to several drivers, and a driver to several vehicles', async () => {
    const asha = await driverSession(h, owner, 'Asha Rao', unlinked);
    const bala = await driverSession(h, owner, 'Bala Iyer', unlinked);
    const v1 = await addVehicle(h, owner, 'MH12LK0001', 'diesel', 48_000, unlinked);
    const v2 = await addVehicle(h, owner, 'MH12LK0002', 'diesel', 48_000, unlinked);

    const linked = await setDrivers(v1.id, [bala.driverId, asha.driverId]).expect(200);
    expect((linked.body as Linked).drivers).toEqual([
      { id: asha.driverId, name: 'Asha Rao' },
      { id: bala.driverId, name: 'Bala Iyer' },
    ]);
    const res = await request(h.http)
      .put(`/v1/drivers/${asha.driverId}/vehicles`)
      .set(...bearer(owner))
      .send({ vehicleIds: [v1.id, v2.id] })
      .expect(200);
    expect(res.body).toMatchObject({
      vehicles: [
        { id: v1.id, registrationNo: 'MH12LK0001' },
        { id: v2.id, registrationNo: 'MH12LK0002' },
      ],
    });
    const v2Now = await request(h.http)
      .get(`/v1/vehicles/${v2.id}`)
      .set(...bearer(owner))
      .expect(200);
    expect((v2Now.body as Linked).drivers.map((d) => d.id)).toEqual([asha.driverId]);

    // A driver sees only their vehicles.
    const mine = await request(h.http)
      .get('/v1/vehicles')
      .set(...bearer(bala.session))
      .expect(200);
    expect((mine.body as Linked[]).map((v) => v.id)).toEqual([v1.id]);
  });

  it('only lets trips pair a driver with a vehicle they are linked to', async () => {
    const driver = await driverSession(h, owner, 'Chetan Das', unlinked);
    const vehicle = await addVehicle(h, owner, 'MH12LK0003', 'diesel', 48_000, unlinked);
    const refused = await trip(vehicle.id, driver.driverId).expect(409);
    expect(refused.body).toMatchObject({
      error: {
        code: 'DRIVER_NOT_LINKED',
        details: { driverName: 'Chetan Das', registrationNo: 'MH12LK0003' },
      },
    });
    // Drivers creating their own trip can only pick their vehicles too.
    await trip(vehicle.id, driver.driverId, driver.session).expect(409);

    await setDrivers(vehicle.id, [driver.driverId]).expect(200);
    await trip(vehicle.id, driver.driverId).expect(201);
  });

  it("won't unlink a pair that has an assigned trip until it's reassigned", async () => {
    const driver = await driverSession(h, owner, 'Deepa Nair', unlinked);
    const vehicle = await addVehicle(h, owner, 'MH12LK0004', 'diesel', 48_000, unlinked);
    await setDrivers(vehicle.id, [driver.driverId]).expect(200);
    const booked = await trip(vehicle.id, driver.driverId).expect(201);
    const tripId = (booked.body as { id: string }).id;

    const refused = await setDrivers(vehicle.id, []).expect(409);
    expect(refused.body).toMatchObject({
      error: { code: 'LINK_IN_USE', details: { tripIds: [tripId] } },
    });
    await request(h.http)
      .put(`/v1/drivers/${driver.driverId}/vehicles`)
      .set(...bearer(owner))
      .send({ vehicleIds: [] })
      .expect(409);

    await request(h.http)
      .post(`/v1/trips/${tripId}/unassign`)
      .set(...bearer(owner))
      .set(...key())
      .expect(200);
    const cleared = await setDrivers(vehicle.id, []).expect(200);
    expect((cleared.body as Linked).drivers).toEqual([]);
  });

  it('links drivers given when adding a vehicle or inviting a driver', async () => {
    const vehicle = await addVehicle(h, owner, 'MH12LK0005', 'diesel', 48_000, unlinked);
    const invite = await request(h.http)
      .post('/v1/drivers')
      .set(...bearer(owner))
      .send({ name: 'Esha Kapoor', phone: randomPhone(), vehicleIds: [vehicle.id] })
      .expect(201);
    expect(invite.body).toMatchObject({ vehicles: [{ id: vehicle.id }] });
    const driverId = (invite.body as { id: string }).id;
    const added = await request(h.http)
      .post('/v1/vehicles')
      .set(...bearer(owner))
      .send({
        registrationNo: 'MH12LK0006',
        make: 'Maruti',
        model: 'Ertiga',
        fuelType: 'cng',
        driverIds: [driverId],
      })
      .expect(201);
    expect((added.body as Linked).drivers.map((d) => d.id)).toEqual([driverId]);
  });

  it('rejects unknown, repeated or other-org ids', async () => {
    const vehicle = await addVehicle(h, owner, 'MH12LK0007', 'diesel', 48_000, unlinked);
    const driver = await driverSession(h, owner, 'Farah Khan', unlinked);
    await setDrivers(vehicle.id, [randomUUID()]).expect(404);
    await setDrivers(vehicle.id, [driver.driverId, driver.driverId]).expect(400);
    const otherOwner = await ownerSession(h, 'fleet', 'Other Travels');
    const outsider = await driverSession(h, otherOwner, 'Outsider', unlinked);
    await setDrivers(vehicle.id, [outsider.driverId]).expect(404);
  });

  it('managers can link, drivers cannot', async () => {
    const vehicle = await addVehicle(h, owner, 'MH12LK0008', 'diesel', 48_000, unlinked);
    const driver = await driverSession(h, owner, 'Gita Sen', unlinked);
    const res = await request(h.http)
      .put(`/v1/vehicles/${vehicle.id}/drivers`)
      .set(...bearer(driver.session))
      .send({ driverIds: [driver.driverId] })
      .expect(403);
    expect(res.body).toMatchObject({ error: { code: 'FORBIDDEN_ROLE' } });
  });

  it('links an owner-driver to every vehicle they add', async () => {
    const dco = await ownerSession(h, 'dco', 'Solo Cabs');
    const res = await request(h.http)
      .post('/v1/vehicles')
      .set(...bearer(dco))
      .send({ registrationNo: 'MH12LK0009', make: 'Toyota', model: 'Etios', fuelType: 'diesel' })
      .expect(201);
    expect((res.body as Linked).drivers).toHaveLength(1);
  });
});

describe('documents and expiry alerts', () => {
  async function alertsFor(subjectId: string) {
    return h.owner.alert.findMany({ where: { subjectId }, orderBy: { createdAt: 'asc' } });
  }

  it('raises an alert straight away for a document already inside the window', async () => {
    const vehicle = await createVehicle(owner, 'MH12DC0001');
    const res = await request(h.http)
      .post('/v1/documents')
      .set(...bearer(owner))
      .send({ docType: 'insurance', vehicleId: vehicle.id, expiresOn: addDays(5), number: 'POL-1' })
      .expect(201);
    const doc = res.body as { id: string; status: string; daysLeft: number };
    expect(doc).toMatchObject({ status: 'expiring', daysLeft: 5 });
    const alerts = await alertsFor(doc.id);
    expect(alerts).toMatchObject([
      {
        kind: 'document_expiring',
        severity: 'warning',
        status: 'open',
        title: 'Insurance for MH12DC0001 expires in 5 days',
      },
    ]);
  });

  it('only the current bucket stays open as the date approaches, and renewal clears it', async () => {
    const vehicle = await createVehicle(owner, 'MH12DC0002');
    const created = await request(h.http)
      .post('/v1/documents')
      .set(...bearer(owner))
      .send({ docType: 'puc', vehicleId: vehicle.id, expiresOn: addDays(20) })
      .expect(201);
    const docId = (created.body as { id: string }).id;
    expect((await alertsFor(docId)).map((a) => [a.dedupeKey.split(':')[2], a.status])).toEqual([
      ['30', 'open'],
    ]);

    // Time passes: the document is now 1 day from expiry.
    await h.owner.document.update({
      where: { id: docId },
      data: { expiresOn: new Date(`${addDays(1)}T00:00:00Z`) },
    });
    await runSchedule(h, 'fleet.document_expiry_scan');
    const states = (await alertsFor(docId)).map((a) => [
      a.dedupeKey.split(':')[2],
      a.status,
      a.severity,
    ]);
    // Order-independent: both alerts can carry the same createdAt millisecond.
    expect(states).toHaveLength(2);
    expect(states).toEqual(
      expect.arrayContaining([
        ['30', 'resolved', 'info'],
        ['1', 'open', 'critical'],
      ]),
    );

    const renewed = await request(h.http)
      .post(`/v1/documents/${docId}/renew`)
      .set(...bearer(owner))
      .send({ expiresOn: addDays(365) })
      .expect(201);
    expect(renewed.body).toMatchObject({ status: 'valid', docType: 'puc', vehicleId: vehicle.id });
    expect((await alertsFor(docId)).every((a) => a.status === 'resolved')).toBe(true);

    const current = await request(h.http)
      .get(`/v1/documents?vehicleId=${vehicle.id}`)
      .set(...bearer(owner))
      .expect(200);
    expect((current.body as { id: string }[]).map((d) => d.id)).toEqual([
      (renewed.body as { id: string }).id,
    ]);
  });

  it('flags expired documents', async () => {
    const { driverId } = await driverSession(h, owner);
    const res = await request(h.http)
      .post('/v1/documents')
      .set(...bearer(owner))
      .send({ docType: 'driving_licence', driverId, expiresOn: addDays(-2) })
      .expect(201);
    expect(res.body).toMatchObject({ status: 'expired', daysLeft: -2 });
    expect(await alertsFor((res.body as { id: string }).id)).toMatchObject([
      { kind: 'document_expired', severity: 'critical' },
    ]);
  });

  it('keeps licences on drivers and the rest on vehicles', async () => {
    const vehicle = await createVehicle(owner, 'MH12DC0003');
    const res = await request(h.http)
      .post('/v1/documents')
      .set(...bearer(owner))
      .send({ docType: 'driving_licence', vehicleId: vehicle.id, expiresOn: addDays(100) })
      .expect(400);
    expect(res.body).toMatchObject({ error: { code: 'VALIDATION_FAILED' } });
  });
});

describe('settings', () => {
  it('reads defaults and lets the owner change them', async () => {
    const defaults = await request(h.http)
      .get('/v1/settings/audit')
      .set(...bearer(owner))
      .expect(200);
    expect(defaults.body).toEqual({
      fuelKSigma: 2,
      fuelMinCycles: 3,
      fuelPctThreshold: 20,
      fuelEwmaAlpha: 0.3,
      odoGpsTolerancePct: 10,
      docAlertDays: [30, 7, 1],
    });
    const updated = await request(h.http)
      .patch('/v1/settings/audit')
      .set(...bearer(owner))
      .send({ fuelKSigma: 2.5 })
      .expect(200);
    expect(updated.body).toMatchObject({ fuelKSigma: 2.5, fuelMinCycles: 3 });

    const pay = { kind: 'percent_of_fare', percent: 20, base: 'quoted', allowanceToDriver: true };
    await request(h.http)
      .put('/v1/settings/driver-pay')
      .set(...bearer(owner))
      .send(pay)
      .expect(200);
    expect(
      (
        await request(h.http)
          .get('/v1/settings/driver-pay')
          .set(...bearer(owner))
          .expect(200)
      ).body,
    ).toEqual(pay);
  });
});
