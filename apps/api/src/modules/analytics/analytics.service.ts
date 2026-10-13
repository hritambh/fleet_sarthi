import { Injectable } from '@nestjs/common';
import type { DailyAnalytics, DashboardSummary } from '@taxcy/contracts';
import type { TenantTx } from '@taxcy/db';
import {
  buildDailyAnalytics,
  istBusinessDate,
  tripClosedAt,
  tripRevenuePaise,
  type AnalyticsTrip,
} from '@taxcy/domain';
import type { TenantAuth } from '../../platform/auth/auth-context.js';
import { Db } from '../../platform/prisma.service.js';

const DAY_MS = 24 * 60 * 60 * 1000;
const istDayStart = (date: string) => new Date(`${date}T00:00:00+05:30`);

function nextMonth(month: string): string {
  const [y, m] = month.split('-').map(Number) as [number, number];
  return m === 12 ? `${y + 1}-01` : `${y}-${String(m + 1).padStart(2, '0')}`;
}

@Injectable()
export class AnalyticsService {
  constructor(private readonly db: Db) {}

  async daily(auth: TenantAuth, month: string): Promise<DailyAnalytics> {
    const start = istDayStart(`${month}-01`);
    const end = istDayStart(`${nextMonth(month)}-01`);
    return this.db.tenant(auth.orgId, async (tx) => {
      const [vehicles, trips, fills] = await Promise.all([
        tx.vehicle.findMany({
          where: { orgId: tx.orgId },
          select: { id: true, registrationNo: true, model: true, fuelType: true },
          orderBy: { registrationNo: 'asc' },
        }),
        this.closedTrips(tx, start, end),
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
      ]);
      const { rows, perTrip } = buildDailyAnalytics(
        month,
        trips,
        fills.map((f) => ({ ...f, costPaise: Number(f.costPaise) })),
      );
      return { month, vehicles, rows, perTrip };
    });
  }

  async dashboard(auth: TenantAuth, date: Date, now = new Date()): Promise<DashboardSummary> {
    const day = date.toISOString().slice(0, 10);
    const dayStart = istDayStart(day);
    const dayEnd = new Date(dayStart.getTime() + DAY_MS);
    const prevStart = new Date(dayStart.getTime() - DAY_MS);
    const todayStart = istDayStart(istBusinessDate(now));
    const todayEnd = new Date(todayStart.getTime() + DAY_MS);

    return this.db.tenant(auth.orgId, async (tx) => {
      const [vehicles, drivers, running, assignedToday, unassigned, closed] = await Promise.all([
        tx.vehicle.findMany({ where: { orgId: tx.orgId }, select: { id: true, status: true } }),
        tx.driver.findMany({ where: { orgId: tx.orgId }, select: { id: true, status: true } }),
        tx.trip.findMany({
          where: { orgId: tx.orgId, status: 'started' },
          select: { vehicleId: true, driverId: true },
        }),
        tx.trip.findMany({
          where: {
            orgId: tx.orgId,
            status: 'assigned',
            driverId: { not: null },
            scheduledStartAt: { gte: now, lt: todayEnd },
          },
          select: { driverId: true },
        }),
        tx.trip.count({
          where: { orgId: tx.orgId, status: 'created' },
        }),
        this.closedTrips(tx, prevStart, dayEnd),
      ]);

      const activeVehicles = new Set(
        vehicles.filter((v) => v.status === 'active').map((v) => v.id),
      );
      const vehiclesOnTrip = new Set(
        running
          .map((t) => t.vehicleId)
          .filter((id): id is string => !!id && activeVehicles.has(id)),
      );
      const activeDrivers = new Set(drivers.filter((d) => d.status === 'active').map((d) => d.id));
      const driversOnTrip = new Set(
        running.map((t) => t.driverId).filter((id): id is string => !!id && activeDrivers.has(id)),
      );
      const driversAssigned = new Set(
        assignedToday
          .map((t) => t.driverId)
          .filter((id): id is string => !!id && activeDrivers.has(id) && !driversOnTrip.has(id)),
      );

      let count = 0;
      let grossPaise = 0;
      let previousDayCount = 0;
      for (const t of closed) {
        const closedAt = tripClosedAt(t);
        if (!closedAt) continue;
        if (istBusinessDate(closedAt) === day) {
          count += 1;
          grossPaise += tripRevenuePaise(t);
        } else {
          previousDayCount += 1;
        }
      }

      return {
        date,
        cabs: {
          total: activeVehicles.size,
          available: activeVehicles.size - vehiclesOnTrip.size,
          onTrip: vehiclesOnTrip.size,
          inactive: vehicles.length - activeVehicles.size,
        },
        drivers: {
          total: activeDrivers.size,
          available: activeDrivers.size - driversOnTrip.size - driversAssigned.size,
          onTrip: driversOnTrip.size,
          assigned: driversAssigned.size,
        },
        unassigned,
        completed: { count, grossPaise, previousDayCount },
      };
    });
  }

  /** Trips that closed (ended, or cancelled after starting) in [start, end), with their km. */
  private async closedTrips(tx: TenantTx, start: Date, end: Date): Promise<AnalyticsTrip[]> {
    const rows = await tx.trip.findMany({
      where: {
        orgId: tx.orgId,
        OR: [
          { status: { in: ['ended', 'settled'] }, endedAt: { gte: start, lt: end } },
          { status: 'cancelled', startedAt: { not: null }, cancelledAt: { gte: start, lt: end } },
        ],
      },
      select: {
        vehicleId: true,
        status: true,
        quotedFarePaise: true,
        cancellationFarePaise: true,
        startedAt: true,
        endedAt: true,
        cancelledAt: true,
        startOdometerId: true,
        endOdometerId: true,
        charges: { where: { voidedAt: null }, select: { amountPaise: true } },
      },
    });
    const odometerIds = rows.flatMap((r) =>
      r.startOdometerId && r.endOdometerId ? [r.startOdometerId, r.endOdometerId] : [],
    );
    const readings = odometerIds.length
      ? await tx.odometerReading.findMany({
          where: { id: { in: odometerIds } },
          select: { id: true, typedKm: true },
        })
      : [];
    const km = new Map(readings.map((r) => [r.id, r.typedKm]));
    return rows.map((r) => {
      const startKm = r.startOdometerId ? km.get(r.startOdometerId) : undefined;
      const endKm = r.endOdometerId ? km.get(r.endOdometerId) : undefined;
      return {
        vehicleId: r.vehicleId,
        status: r.status,
        quotedFarePaise: Number(r.quotedFarePaise),
        cancellationFarePaise:
          r.cancellationFarePaise === null ? null : Number(r.cancellationFarePaise),
        startedAt: r.startedAt,
        endedAt: r.endedAt,
        cancelledAt: r.cancelledAt,
        chargesPaise: r.charges.map((c) => Number(c.amountPaise)),
        km: startKm === undefined || endKm === undefined ? null : endKm - startKm,
      };
    });
  }
}
