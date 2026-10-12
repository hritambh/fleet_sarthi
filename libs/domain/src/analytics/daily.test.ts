import { describe, expect, it } from 'vitest';
import {
  buildDailyAnalytics,
  tripClosedAt,
  tripRevenuePaise,
  type AnalyticsFill,
  type AnalyticsTrip,
} from './daily.js';

const trip = (over: Partial<AnalyticsTrip> = {}): AnalyticsTrip => ({
  vehicleId: 'v1',
  status: 'ended',
  quotedFarePaise: 100_000,
  cancellationFarePaise: null,
  startedAt: new Date('2026-10-05T03:00:00Z'),
  endedAt: new Date('2026-10-05T10:00:00Z'),
  cancelledAt: null,
  chargesPaise: [],
  km: 100,
  ...over,
});

const fill = (over: Partial<AnalyticsFill> = {}): AnalyticsFill => ({
  vehicleId: 'v1',
  fuel: 'diesel',
  quantityMilli: 20_000,
  costPaise: 200_000,
  filledAt: new Date('2026-10-05T05:00:00Z'),
  ...over,
});

describe('tripClosedAt', () => {
  it('counts ended and settled trips on their end time', () => {
    expect(tripClosedAt(trip())).toEqual(new Date('2026-10-05T10:00:00Z'));
    expect(tripClosedAt(trip({ status: 'settled' }))).toEqual(new Date('2026-10-05T10:00:00Z'));
  });

  it('counts a cancel-after-start on its cancel time, but not a cancel before start', () => {
    const cancelledAt = new Date('2026-10-05T06:00:00Z');
    expect(tripClosedAt(trip({ status: 'cancelled', endedAt: null, cancelledAt }))).toEqual(
      cancelledAt,
    );
    expect(
      tripClosedAt(trip({ status: 'cancelled', startedAt: null, endedAt: null, cancelledAt })),
    ).toBeNull();
  });

  it('ignores open trips', () => {
    expect(tripClosedAt(trip({ status: 'started', endedAt: null }))).toBeNull();
  });
});

describe('tripRevenuePaise', () => {
  it('is the fare plus every charge, tolls included', () => {
    expect(tripRevenuePaise(trip({ chargesPaise: [5_000, 2_500] }))).toBe(107_500);
  });

  it('uses the cancellation fare for a cancelled trip', () => {
    expect(
      tripRevenuePaise(
        trip({ status: 'cancelled', cancellationFarePaise: 30_000, chargesPaise: [1_000] }),
      ),
    ).toBe(31_000);
    expect(tripRevenuePaise(trip({ status: 'cancelled' }))).toBe(0);
  });
});

describe('buildDailyAnalytics', () => {
  it('buckets fills and trips by IST day and vehicle, keeping units apart', () => {
    const { rows } = buildDailyAnalytics(
      '2026-10',
      [
        trip(),
        // 2026-10-05T20:00Z is 6 October in IST.
        trip({ endedAt: new Date('2026-10-05T20:00:00Z'), km: 50 }),
      ],
      [fill(), fill({ vehicleId: 'v2', fuel: 'cng', quantityMilli: 8_000, costPaise: 70_000 })],
    );
    expect(rows).toEqual([
      {
        date: '2026-10-05',
        vehicleId: 'v1',
        fuelLitresMilli: 20_000,
        fuelKgMilli: 0,
        fuelCostPaise: 200_000,
        revenuePaise: 100_000,
        km: 100,
        trips: 1,
      },
      {
        date: '2026-10-05',
        vehicleId: 'v2',
        fuelLitresMilli: 0,
        fuelKgMilli: 8_000,
        fuelCostPaise: 70_000,
        revenuePaise: 0,
        km: 0,
        trips: 0,
      },
      {
        date: '2026-10-06',
        vehicleId: 'v1',
        fuelLitresMilli: 0,
        fuelKgMilli: 0,
        fuelCostPaise: 0,
        revenuePaise: 100_000,
        km: 50,
        trips: 1,
      },
    ]);
  });

  it('drops activity outside the month and trips without a vehicle', () => {
    const { rows, perTrip } = buildDailyAnalytics(
      '2026-10',
      [trip({ endedAt: new Date('2026-09-30T10:00:00Z') }), trip({ vehicleId: null })],
      [fill({ filledAt: new Date('2026-11-01T00:00:00Z') })],
    );
    expect(rows).toEqual([]);
    expect(perTrip).toEqual({
      trips: 0,
      kmAvg: null,
      revenueAvgPaise: null,
      fuelCostAvgPaise: null,
    });
  });

  it('averages km, revenue and estimated fuel cost per trip', () => {
    const { perTrip } = buildDailyAnalytics(
      '2026-10',
      [
        trip({ km: 100, chargesPaise: [10_000] }),
        trip({ km: 300, quotedFarePaise: 300_000 }),
        // No odometer km: counts for revenue, not for km or fuel cost.
        trip({ km: null, quotedFarePaise: 50_000 }),
      ],
      // v1 spent ₹2,000 over 400 trip km: ₹5/km.
      [fill()],
    );
    expect(perTrip).toEqual({
      trips: 3,
      kmAvg: 200,
      revenueAvgPaise: Math.round((110_000 + 300_000 + 50_000) / 3),
      fuelCostAvgPaise: 100_000,
    });
  });
});
