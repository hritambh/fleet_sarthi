import type { DailyAnalytics, DashboardSummary, Session, Trip } from '@taxcy/contracts';
import { istBusinessDate } from '@taxcy/domain';
import { randomUUID } from 'node:crypto';
import request from 'supertest';
import { afterAll, beforeAll, describe, expect, it } from 'vitest';
import {
  bearer,
  createVehicle,
  driverSession,
  key,
  odometer,
  ownerSession,
  registerPhoto,
  schedule,
  startHarness,
  type Harness,
} from './harness.js';

let h: Harness;
let owner: Session;
let driver: { session: Session; driverId: string };
let vehicle: { id: string };

const today = () => istBusinessDate(new Date());
const month = () => today().slice(0, 7);
const rupees = (r: number) => r * 100;

async function createTrip(fareRupees: number, assign = true): Promise<Trip> {
  return (
    await request(h.http)
      .post('/v1/trips')
      .set(...bearer(owner))
      .send({
        tripType: 'one_way',
        from: { text: 'Pune' },
        to: { text: 'Mumbai' },
        ...schedule(),
        quotedFarePaise: rupees(fareRupees),
        ...(assign ? { vehicleId: vehicle.id, driverId: driver.driverId } : {}),
      })
      .expect(201)
  ).body as Trip;
}

async function runTrip(fareRupees: number, startKm: number, endKm: number, tollRupees = 0) {
  const trip = await createTrip(fareRupees);
  await request(h.http)
    .post(`/v1/trips/${trip.id}/start`)
    .set(...bearer(driver.session))
    .set(...key())
    .send({
      odometer: await odometer(h, driver.session, startKm),
      occurredAt: new Date().toISOString(),
    })
    .expect(200);
  await request(h.http)
    .post(`/v1/trips/${trip.id}/end`)
    .set(...bearer(driver.session))
    .set(...key())
    .send({
      odometer: await odometer(h, driver.session, endKm),
      occurredAt: new Date().toISOString(),
      charges: tollRupees
        ? [{ id: randomUUID(), kind: 'toll', amountPaise: rupees(tollRupees), paidByDriver: true }]
        : [],
    })
    .expect(200);
}

beforeAll(async () => {
  h = await startHarness();
  owner = await ownerSession(h, 'fleet', 'Analytics Travels');
  vehicle = await createVehicle(h, owner, 'MH12AN0001', 'diesel', 10_000);
  driver = await driverSession(h, owner);

  await runTrip(2_000, 10_000, 10_150, 250);
  await runTrip(3_000, 10_150, 10_400);
  await request(h.http)
    .post('/v1/fuel-fills')
    .set(...bearer(driver.session))
    .send({
      id: randomUUID(),
      vehicleId: vehicle.id,
      fuel: 'diesel',
      quantityMilli: 30_000,
      costPaise: rupees(2_700),
      odometer: await odometer(h, driver.session, 10_400),
      isFullTank: true,
      receiptMediaId: await registerPhoto(h, driver.session, 'fuel_receipt'),
      paidBy: 'driver_cash',
      filledAt: new Date().toISOString(),
    })
    .expect(201);
  await createTrip(1_500, false);
});

afterAll(async () => {
  await h.close();
});

describe('GET /analytics/daily', () => {
  it("sums today's fuel, revenue and km for the vehicle", async () => {
    const body = (
      await request(h.http)
        .get('/v1/analytics/daily')
        .query({ month: month() })
        .set(...bearer(owner))
        .expect(200)
    ).body as DailyAnalytics;

    expect(body.vehicles.map((v) => v.registrationNo)).toEqual(['MH12AN0001']);
    expect(body.rows).toEqual([
      {
        date: today(),
        vehicleId: vehicle.id,
        fuelLitresMilli: 30_000,
        fuelKgMilli: 0,
        fuelCostPaise: rupees(2_700),
        revenuePaise: rupees(2_000 + 250 + 3_000),
        km: 400,
        trips: 2,
      },
    ]);
    expect(body.perTrip).toEqual({
      trips: 2,
      kmAvg: 200,
      revenueAvgPaise: rupees(5_250) / 2,
      fuelCostAvgPaise: rupees(2_700) / 2,
    });
  });

  it('rejects a malformed month', async () => {
    await request(h.http)
      .get('/v1/analytics/daily')
      .query({ month: '2026-13' })
      .set(...bearer(owner))
      .expect(400);
  });

  it('is for staff only', async () => {
    await request(h.http)
      .get('/v1/analytics/daily')
      .query({ month: month() })
      .set(...bearer(driver.session))
      .expect(403);
  });
});

describe('GET /analytics/dashboard', () => {
  it("counts cabs, drivers, the unassigned queue and today's completed trips", async () => {
    const body = (
      await request(h.http)
        .get('/v1/analytics/dashboard')
        .query({ date: today() })
        .set(...bearer(owner))
        .expect(200)
    ).body as DashboardSummary;

    expect(body).toMatchObject({
      date: today(),
      cabs: { total: 1, available: 1, onTrip: 0, inactive: 0 },
      drivers: { total: 1, available: 1, onTrip: 0, assigned: 0 },
      unassigned: 1,
      completed: { count: 2, grossPaise: rupees(5_250), previousDayCount: 0 },
    });
  });
});
