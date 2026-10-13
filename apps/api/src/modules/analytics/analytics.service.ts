import { Injectable } from '@nestjs/common';
import type { AnalyticsVehicle, FuelUnit, MonthlyAnalytics } from '@taxcy/contracts';
import { istBusinessDate } from '@taxcy/domain';
import type { TenantAuth } from '../../platform/auth/auth-context.js';
import { Db } from '../../platform/prisma.service.js';

const DAY_MS = 86_400_000;

const istDayStart = (day: string) => new Date(`${day}T00:00:00+05:30`);

/** A fill of CNG is weighed in kilograms; petrol and diesel are measured in litres. */
const unitFor = (fuel: string): FuelUnit => (fuel === 'cng' ? 'kg' : 'L');

/** A quantity in millilitres (petrol, diesel) or grams (CNG) becomes litres or kg. */
const toUnit = (quantityMilli: number) => quantityMilli / 1000;

const dayKey = (year: number, month: number, day: number) =>
  `${String(year)}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;

/**
 * The IST days of a month that have already happened. A month still running stops at
 * today, so charts do not trail off across days that cannot have data yet.
 */
function monthDays(year: number, month: number, today: string): string[] {
  const lastDay = new Date(Date.UTC(year, month, 0)).getUTCDate();
  const days: string[] = [];
  for (let d = 1; d <= lastDay; d++) {
    const key = dayKey(year, month, d);
    if (key > today) break;
    days.push(key);
  }
  return days;
}

/** Zero-filled series, one slot per day, so every vehicle covers the whole month. */
const zeros = (n: number) => Array.from({ length: n }, () => 0);

/** Adds to one day of a series. Reading with `?? 0` keeps this free of assertions. */
const addAt = (series: number[], i: number, delta: number) => {
  series[i] = (series[i] ?? 0) + delta;
};

const divide = (total: number, count: number) => (count === 0 ? null : total / count);

@Injectable()
export class AnalyticsService {
  constructor(private readonly db: Db) {}

  async monthly(
    auth: TenantAuth,
    query: { year: number; month: number },
  ): Promise<MonthlyAnalytics> {
    const { year, month } = query;
    const days = monthDays(year, month, istBusinessDate(new Date()));
    const slot = new Map(days.map((day, i) => [day, i]));
    const n = days.length;

    return this.db.tenant(auth.orgId, async (tx) => {
      const vehicleRows = await tx.vehicle.findMany({
        orderBy: { registrationNo: 'asc' },
        select: { id: true, registrationNo: true, make: true, model: true, fuelType: true },
      });
      const vehicles: AnalyticsVehicle[] = vehicleRows.map((v) => ({
        id: v.id,
        registrationNo: v.registrationNo,
        make: v.make,
        model: v.model,
        fuelType: v.fuelType,
      }));

      // Filled in from the month's fills: one row per vehicle and unit actually used.
      const fuel: MonthlyAnalytics['fuel'] = [];
      const revenue = vehicles.map((v) => ({
        vehicleId: v.id,
        billedPaise: zeros(n),
        collectedPaise: zeros(n),
      }));
      const distance = vehicles.map((v) => ({ vehicleId: v.id, km: zeros(n) }));
      const distanceTotalKm = zeros(n);
      const perTrip: MonthlyAnalytics['perTrip'] = {
        trips: zeros(n),
        activeVehicles: zeros(n),
        revenuePerTripPaise: zeros(n),
        kmPerTrip: zeros(n),
        fuelCostPerTripPaise: zeros(n),
        tripsPerVehicle: zeros(n),
      };
      const result: MonthlyAnalytics = {
        year,
        month,
        days,
        vehicles,
        fuel,
        revenue,
        distance,
        distanceTotalKm,
        perTrip,
      };

      const first = days[0];
      const last = days[n - 1];
      if (first === undefined || last === undefined || vehicles.length === 0) return result;

      const start = istDayStart(first);
      const end = new Date(istDayStart(last).getTime() + DAY_MS);
      const rowOf = new Map(vehicles.map((v, i) => [v.id, i]));

      const [fills, trips] = await Promise.all([
        tx.fuelFill.findMany({
          where: { orgId: tx.orgId, voidedAt: null, filledAt: { gte: start, lt: end } },
          select: {
            vehicleId: true,
            fuel: true,
            quantityMilli: true,
            costPaise: true,
            filledAt: true,
          },
        }),
        // A trip counts on the IST day it closed, matching how settlements group them.
        tx.trip.findMany({
          where: {
            orgId: tx.orgId,
            vehicleId: { not: null },
            OR: [
              { status: { in: ['ended', 'settled'] }, endedAt: { gte: start, lt: end } },
              {
                status: 'cancelled',
                cancelledAt: { gte: start, lt: end },
                startedAt: { not: null },
              },
            ],
          },
          select: {
            id: true,
            vehicleId: true,
            status: true,
            endedAt: true,
            cancelledAt: true,
            quotedFarePaise: true,
            cancellationFarePaise: true,
            startOdometerId: true,
            endOdometerId: true,
            charges: { where: { voidedAt: null }, select: { amountPaise: true } },
            collections: { select: { amountPaise: true } },
          },
        }),
      ]);

      const odometerIds = trips
        .flatMap((t) => [t.startOdometerId, t.endOdometerId])
        .filter((id): id is string => id !== null);
      const readings =
        odometerIds.length === 0
          ? []
          : await tx.odometerReading.findMany({
              where: { id: { in: odometerIds } },
              select: { id: true, typedKm: true },
            });
      const kmAt = new Map(readings.map((r) => [r.id, r.typedKm]));

      const fuelCostByDay = zeros(n);
      const billedByDay = zeros(n);
      const kmByDay = zeros(n);
      const tripsWithKmByDay = zeros(n);
      const vehiclesByDay = new Map<number, Set<string>>();

      // Fuel counts for the day it was filled, whether or not it was on a trip.
      const fuelRows = new Map<string, MonthlyAnalytics['fuel'][number]>();
      for (const fill of fills) {
        const i = slot.get(istBusinessDate(fill.filledAt));
        if (i === undefined || !rowOf.has(fill.vehicleId)) continue;
        const unit = unitFor(fill.fuel);
        const key = `${fill.vehicleId}:${unit}`;
        let entry = fuelRows.get(key);
        if (entry === undefined) {
          entry = { vehicleId: fill.vehicleId, unit, quantity: zeros(n), costPaise: zeros(n) };
          fuelRows.set(key, entry);
        }
        const cost = Number(fill.costPaise);
        addAt(entry.quantity, i, toUnit(fill.quantityMilli));
        addAt(entry.costPaise, i, cost);
        addAt(fuelCostByDay, i, cost);
      }
      // Fleet order, so a chart's colours do not move when a vehicle has no fills.
      fuel.push(
        ...[...fuelRows.values()].sort(
          (a, b) =>
            (rowOf.get(a.vehicleId) ?? 0) - (rowOf.get(b.vehicleId) ?? 0) ||
            a.unit.localeCompare(b.unit),
        ),
      );

      for (const trip of trips) {
        const closedAt = trip.endedAt ?? trip.cancelledAt;
        if (closedAt === null || trip.vehicleId === null) continue;
        const i = slot.get(istBusinessDate(closedAt));
        const row = rowOf.get(trip.vehicleId);
        const rev = row === undefined ? undefined : revenue[row];
        const dist = row === undefined ? undefined : distance[row];
        if (i === undefined || rev === undefined || dist === undefined) continue;

        // A cancelled trip earns only its cancellation fare, as in settlements.
        const fare =
          trip.status === 'cancelled'
            ? Number(trip.cancellationFarePaise ?? 0n)
            : Number(trip.quotedFarePaise);
        // Every charge is billed to the customer, as in settlements. Who paid it out of
        // pocket only decides who gets reimbursed, so it does not change revenue.
        const extras = trip.charges.reduce((sum, c) => sum + Number(c.amountPaise), 0);
        const billed = fare + extras;
        const collected = trip.collections.reduce((sum, c) => sum + Number(c.amountPaise), 0);

        addAt(rev.billedPaise, i, billed);
        addAt(rev.collectedPaise, i, collected);
        addAt(billedByDay, i, billed);

        const startKm = trip.startOdometerId === null ? undefined : kmAt.get(trip.startOdometerId);
        const endKm = trip.endOdometerId === null ? undefined : kmAt.get(trip.endOdometerId);
        if (startKm !== undefined && endKm !== undefined && endKm >= startKm) {
          const km = endKm - startKm;
          addAt(dist.km, i, km);
          addAt(distanceTotalKm, i, km);
          addAt(kmByDay, i, km);
          addAt(tripsWithKmByDay, i, 1);
        }

        addAt(perTrip.trips, i, 1);
        const seen = vehiclesByDay.get(i) ?? new Set<string>();
        seen.add(trip.vehicleId);
        vehiclesByDay.set(i, seen);
      }

      for (let i = 0; i < n; i++) {
        const tripCount = perTrip.trips[i] ?? 0;
        const active = vehiclesByDay.get(i)?.size ?? 0;
        perTrip.activeVehicles[i] = active;
        perTrip.revenuePerTripPaise[i] = divide(billedByDay[i] ?? 0, tripCount);
        // Only trips with both odometer readings can contribute a distance.
        perTrip.kmPerTrip[i] = divide(kmByDay[i] ?? 0, tripsWithKmByDay[i] ?? 0);
        perTrip.fuelCostPerTripPaise[i] = divide(fuelCostByDay[i] ?? 0, tripCount);
        perTrip.tripsPerVehicle[i] = divide(tripCount, active);
      }

      return result;
    });
  }
}
