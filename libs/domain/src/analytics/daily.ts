import type { FuelKind } from '../fuel/types.js';
import { istBusinessDate } from '../time.js';

/** A trip as analytics sees it: its fare, its charges and how it closed. */
export interface AnalyticsTrip {
  vehicleId: string | null;
  status: string;
  quotedFarePaise: number;
  cancellationFarePaise: number | null;
  startedAt: Date | null;
  endedAt: Date | null;
  cancelledAt: Date | null;
  /** Non-voided charges only. */
  chargesPaise: readonly number[];
  /** End minus start odometer, or null when either reading is missing. */
  km: number | null;
}

export interface AnalyticsFill {
  vehicleId: string;
  fuel: FuelKind;
  /** Millilitres (petrol, diesel) or grams (CNG). */
  quantityMilli: number;
  costPaise: number;
  filledAt: Date;
}

export interface DailyVehicleRow {
  /** IST calendar date, YYYY-MM-DD. */
  date: string;
  vehicleId: string;
  /** Petrol and diesel, in millilitres. */
  fuelLitresMilli: number;
  /** CNG, in grams. */
  fuelKgMilli: number;
  fuelCostPaise: number;
  revenuePaise: number;
  km: number;
  trips: number;
}

export interface PerTripAverages {
  trips: number;
  kmAvg: number | null;
  revenueAvgPaise: number | null;
  fuelCostAvgPaise: number | null;
}

export interface DailyAnalytics {
  rows: DailyVehicleRow[];
  perTrip: PerTripAverages;
}

/**
 * When a trip counts for revenue and km: the moment it ended, or, for a trip
 * cancelled after it started, the moment it was cancelled. Trips cancelled
 * before starting, and trips still open, never count. Same rule as settlement.
 */
export function tripClosedAt(trip: AnalyticsTrip): Date | null {
  if ((trip.status === 'ended' || trip.status === 'settled') && trip.endedAt) {
    return trip.endedAt;
  }
  if (trip.status === 'cancelled' && trip.startedAt && trip.cancelledAt) {
    return trip.cancelledAt;
  }
  return null;
}

/**
 * Everything the customer is billed for a trip: the quoted fare (or the
 * cancellation fare for a cancel-after-start) plus every non-voided charge,
 * including pass-through ones like tolls and parking.
 */
export function tripRevenuePaise(trip: AnalyticsTrip): number {
  const fare =
    trip.status === 'cancelled' ? (trip.cancellationFarePaise ?? 0) : trip.quotedFarePaise;
  return trip.chargesPaise.reduce((sum, c) => sum + c, fare);
}

const average = (sum: number, n: number) => (n === 0 ? null : Math.round(sum / n));

/**
 * Per-vehicle, per-IST-day fuel bought, revenue and km for one month, plus
 * fleet-wide per-trip averages. `trips` and `fills` may include rows outside
 * the month; they are ignored. Only days with activity get a row.
 */
export function buildDailyAnalytics(
  month: string,
  trips: readonly AnalyticsTrip[],
  fills: readonly AnalyticsFill[],
): DailyAnalytics {
  const rows = new Map<string, DailyVehicleRow>();
  const row = (date: string, vehicleId: string): DailyVehicleRow => {
    const key = `${date}|${vehicleId}`;
    let r = rows.get(key);
    if (!r) {
      r = {
        date,
        vehicleId,
        fuelLitresMilli: 0,
        fuelKgMilli: 0,
        fuelCostPaise: 0,
        revenuePaise: 0,
        km: 0,
        trips: 0,
      };
      rows.set(key, r);
    }
    return r;
  };
  const inMonth = (date: string) => date.startsWith(`${month}-`);

  const vehicleFuelCost = new Map<string, number>();
  const vehicleKm = new Map<string, number>();
  for (const f of fills) {
    const date = istBusinessDate(f.filledAt);
    if (!inMonth(date)) continue;
    const r = row(date, f.vehicleId);
    if (f.fuel === 'cng') r.fuelKgMilli += f.quantityMilli;
    else r.fuelLitresMilli += f.quantityMilli;
    r.fuelCostPaise += f.costPaise;
    vehicleFuelCost.set(f.vehicleId, (vehicleFuelCost.get(f.vehicleId) ?? 0) + f.costPaise);
  }

  const counted: AnalyticsTrip[] = [];
  for (const t of trips) {
    const closedAt = tripClosedAt(t);
    if (!closedAt || !t.vehicleId) continue;
    const date = istBusinessDate(closedAt);
    if (!inMonth(date)) continue;
    counted.push(t);
    const r = row(date, t.vehicleId);
    r.revenuePaise += tripRevenuePaise(t);
    r.km += t.km ?? 0;
    r.trips += 1;
    if (t.km !== null) {
      vehicleKm.set(t.vehicleId, (vehicleKm.get(t.vehicleId) ?? 0) + t.km);
    }
  }

  let kmSum = 0;
  let kmTrips = 0;
  let revenueSum = 0;
  let fuelSum = 0;
  let fuelTrips = 0;
  for (const t of counted) {
    revenueSum += tripRevenuePaise(t);
    if (t.km === null || t.vehicleId === null) continue;
    kmSum += t.km;
    kmTrips += 1;
    // Fuel cost per trip is estimated: the vehicle's fuel spend per km this
    // month, times the trip's km. Vehicles with no trip km are left out.
    const vKm = vehicleKm.get(t.vehicleId) ?? 0;
    if (vKm > 0) {
      fuelSum += ((vehicleFuelCost.get(t.vehicleId) ?? 0) / vKm) * t.km;
      fuelTrips += 1;
    }
  }

  return {
    rows: [...rows.values()].sort(
      (a, b) => a.date.localeCompare(b.date) || a.vehicleId.localeCompare(b.vehicleId),
    ),
    perTrip: {
      trips: counted.length,
      kmAvg: average(kmSum, kmTrips),
      revenueAvgPaise: average(revenueSum, counted.length),
      fuelCostAvgPaise: average(fuelSum, fuelTrips),
    },
  };
}
