import type { Session, Trip } from '@taxcy/contracts';
import { randomUUID } from 'node:crypto';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  bearer,
  createVehicle,
  driverSession,
  login,
  odometer,
  ownerSession,
  randomPhone,
  registerPhoto,
  schedule,
  startHarness,
  type Harness,
} from './harness.js';

let h: Harness;
let owner: Session;
let manager: Session;
let driver: { session: Session; driverId: string };
let vehicle: { id: string };

const workflow = (session: Session) =>
  request(h.http)
    .get('/v1/settings/workflow')
    .set(...bearer(session));
const setWorkflow = (session: Session, body: object) =>
  request(h.http)
    .patch('/v1/settings/workflow')
    .set(...bearer(session))
    .send(body);

/** A trip the driver books for themselves, in the fleet's car. */
const driverTrip = () =>
  request(h.http)
    .post('/v1/trips')
    .set(...bearer(driver.session))
    .send({
      tripType: 'local_rental',
      from: { text: 'Koregaon Park' },
      ...schedule(),
      quotedFarePaise: 150_000,
      vehicleId: vehicle.id,
    });

/** Records a fill and expects [status]. */
const fill = async (receipt: boolean, status: number) =>
  request(h.http)
    .post('/v1/fuel-fills')
    .set(...bearer(driver.session))
    .send({
      id: randomUUID(),
      vehicleId: vehicle.id,
      fuel: 'diesel',
      quantityMilli: 30_000,
      costPaise: 270_000,
      odometer: await odometer(h, driver.session, 48_100),
      isFullTank: true,
      ...(receipt
        ? { receiptMediaId: await registerPhoto(h, driver.session, 'fuel_receipt') }
        : {}),
      paidBy: 'driver_cash',
      filledAt: new Date().toISOString(),
    })
    .expect(status);

beforeAll(async () => {
  h = await startHarness();
  owner = await ownerSession(h, 'fleet', 'Settings Travels');
  vehicle = await createVehicle(h, owner, 'MH12SE0001');
  driver = await driverSession(h, owner);
  const phone = randomPhone();
  await request(h.http)
    .post('/v1/members/managers')
    .set(...bearer(owner))
    .send({ name: 'Priya Manager', phone })
    .expect(201);
  manager = await login(h, phone);
});

afterAll(async () => {
  await h.close();
});

describe('operating rules', () => {
  it("default to today's behaviour, and every member can read them", async () => {
    const expected = {
      driversCanCreateTrips: true,
      driversCanAddCharges: true,
      fuelReceiptRequired: true,
    };
    for (const session of [owner, manager, driver.session]) {
      expect((await workflow(session).expect(200)).body).toEqual(expected);
    }
  });

  it('only the owner can change them', async () => {
    const byManager = await setWorkflow(manager, { driversCanCreateTrips: false }).expect(403);
    expect(byManager.body).toMatchObject({ error: { code: 'FORBIDDEN_ROLE' } });
    await setWorkflow(driver.session, { driversCanCreateTrips: false }).expect(403);
    await setWorkflow(owner, { driversCanCreateTrips: 'no' }).expect(400);
    const updated = await setWorkflow(owner, { fuelReceiptRequired: false }).expect(200);
    expect(updated.body).toEqual({
      driversCanCreateTrips: true,
      driversCanAddCharges: true,
      fuelReceiptRequired: false,
    });
    await setWorkflow(owner, { fuelReceiptRequired: true }).expect(200);
  });

  it('drivers can create trips until the owner turns it off; staff still can', async () => {
    await driverTrip().expect(201);
    await setWorkflow(owner, { driversCanCreateTrips: false }).expect(200);
    const refused = await driverTrip().expect(403);
    expect(refused.body).toMatchObject({ error: { code: 'DRIVER_TRIPS_DISABLED' } });
    await request(h.http)
      .post('/v1/trips')
      .set(...bearer(owner))
      .send({
        tripType: 'local_rental',
        from: { text: 'Baner' },
        ...schedule(),
        quotedFarePaise: 150_000,
        vehicleId: vehicle.id,
        driverId: driver.driverId,
      })
      .expect(201);
    await setWorkflow(owner, { driversCanCreateTrips: true }).expect(200);
  });

  it('a retried create that already went through still succeeds after the rule changes', async () => {
    const id = randomUUID();
    const body = {
      id,
      tripType: 'local_rental',
      from: { text: 'Aundh' },
      ...schedule(),
      quotedFarePaise: 150_000,
      vehicleId: vehicle.id,
    };
    await request(h.http)
      .post('/v1/trips')
      .set(...bearer(driver.session))
      .send(body)
      .expect(201);
    await setWorkflow(owner, { driversCanCreateTrips: false }).expect(200);
    const replay = await request(h.http)
      .post('/v1/trips')
      .set(...bearer(driver.session))
      .send(body)
      .expect(201);
    expect((replay.body as Trip).id).toBe(id);
    await setWorkflow(owner, { driversCanCreateTrips: true }).expect(200);
  });

  it('drivers can add charges until the owner turns it off; staff still can', async () => {
    const trip = (await driverTrip().expect(201)).body as Trip;
    const charge = () => ({
      id: randomUUID(),
      kind: 'toll',
      amountPaise: 12_000,
      paidByDriver: true,
    });
    await request(h.http)
      .post(`/v1/trips/${trip.id}/charges`)
      .set(...bearer(driver.session))
      .send(charge())
      .expect(201);
    await setWorkflow(owner, { driversCanAddCharges: false }).expect(200);
    const refused = await request(h.http)
      .post(`/v1/trips/${trip.id}/charges`)
      .set(...bearer(driver.session))
      .send(charge())
      .expect(403);
    expect(refused.body).toMatchObject({ error: { code: 'DRIVER_CHARGES_DISABLED' } });
    const byOwner = await request(h.http)
      .post(`/v1/trips/${trip.id}/charges`)
      .set(...bearer(owner))
      .send(charge())
      .expect(201);
    // Existing charges are untouched.
    expect((byOwner.body as Trip).charges).toHaveLength(2);
    await setWorkflow(owner, { driversCanAddCharges: true }).expect(200);
  });

  it('a fuel fill needs a receipt unless the owner turns that off', async () => {
    const refused = await fill(false, 422);
    expect(refused.body).toMatchObject({ error: { code: 'RECEIPT_REQUIRED' } });
    await fill(true, 201);
    await setWorkflow(owner, { fuelReceiptRequired: false }).expect(200);
    await fill(false, 201);
    await setWorkflow(owner, { fuelReceiptRequired: true }).expect(200);
  });

  it('are kept per fleet', async () => {
    await setWorkflow(owner, { driversCanAddCharges: false }).expect(200);
    const other = await ownerSession(h, 'fleet', 'Other Travels');
    expect((await workflow(other).expect(200)).body).toMatchObject({ driversCanAddCharges: true });
    await setWorkflow(owner, { driversCanAddCharges: true }).expect(200);
  });
});

describe('fleet name', () => {
  it('staff read it; only the owner renames it, and members see the new name', async () => {
    const profile = await request(h.http)
      .get('/v1/orgs/current')
      .set(...bearer(manager))
      .expect(200);
    expect(profile.body).toMatchObject({ name: 'Settings Travels', kind: 'fleet' });
    await request(h.http)
      .get('/v1/orgs/current')
      .set(...bearer(driver.session))
      .expect(403);
    await request(h.http)
      .patch('/v1/orgs/current')
      .set(...bearer(manager))
      .send({ name: 'Priya Travels' })
      .expect(403);
    const tooShort = await request(h.http)
      .patch('/v1/orgs/current')
      .set(...bearer(owner))
      .send({ name: ' x ' })
      .expect(400);
    expect(tooShort.body).toMatchObject({ error: { code: 'VALIDATION_FAILED' } });

    const renamed = await request(h.http)
      .patch('/v1/orgs/current')
      .set(...bearer(owner))
      .send({ name: '  Sharma Tours & Travels ' })
      .expect(200);
    expect(renamed.body).toMatchObject({ name: 'Sharma Tours & Travels' });
    const me = await request(h.http)
      .get('/v1/me')
      .set(...bearer(driver.session))
      .expect(200);
    expect(JSON.stringify(me.body)).toContain('Sharma Tours & Travels');
  });
});
