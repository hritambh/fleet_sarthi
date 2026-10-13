import { z } from 'zod';
import { CalendarDate, Id, Paise } from '../common.js';
import { access, defineRoute } from '../http.js';
import { FuelType } from './fleet.js';

/** One vehicle on one IST day. Only days with activity are listed. */
export const AnalyticsDayRow = z.object({
  date: z.iso.date(),
  vehicleId: Id,
  /** Petrol and diesel bought, in millilitres. */
  fuelLitresMilli: z.number().int(),
  /** CNG bought, in grams. */
  fuelKgMilli: z.number().int(),
  fuelCostPaise: Paise,
  /** Fare plus every charge (tolls and parking included) of trips closed that day. */
  revenuePaise: Paise,
  /** Odometer km of trips closed that day. */
  km: z.number().int(),
  trips: z.number().int(),
});
export type AnalyticsDayRow = z.infer<typeof AnalyticsDayRow>;

export const DailyAnalytics = z.object({
  month: z.string(),
  vehicles: z.array(
    z.object({ id: Id, registrationNo: z.string(), model: z.string(), fuelType: FuelType }),
  ),
  rows: z.array(AnalyticsDayRow),
  perTrip: z.object({
    trips: z.number().int(),
    kmAvg: z.number().int().nullable(),
    revenueAvgPaise: Paise.nullable(),
    /** Estimated: the vehicle's fuel spend per km this month times the trip's km. */
    fuelCostAvgPaise: Paise.nullable(),
  }),
});
export type DailyAnalytics = z.infer<typeof DailyAnalytics>;

export const DashboardSummary = z.object({
  date: CalendarDate,
  /** Right now, whatever the date. */
  cabs: z.object({
    total: z.number().int(),
    available: z.number().int(),
    onTrip: z.number().int(),
    inactive: z.number().int(),
  }),
  /** Right now, whatever the date. */
  drivers: z.object({
    total: z.number().int(),
    available: z.number().int(),
    onTrip: z.number().int(),
    assigned: z.number().int(),
  }),
  /** Trips not yet assigned a driver and vehicle (status "created"), overdue ones included. */
  unassigned: z.number().int(),
  completed: z.object({
    count: z.number().int(),
    grossPaise: Paise,
    previousDayCount: z.number().int(),
  }),
});
export type DashboardSummary = z.infer<typeof DashboardSummary>;

export const analyticsRoutes = {
  daily: defineRoute({
    method: 'GET',
    path: '/analytics/daily',
    summary: 'Fuel bought, revenue and km per vehicle per IST day for a month',
    tag: 'analytics',
    access: access.staff,
    query: z.object({ month: z.string().regex(/^\d{4}-(0[1-9]|1[0-2])$/) }),
    response: DailyAnalytics,
  }),
  dashboard: defineRoute({
    method: 'GET',
    path: '/analytics/dashboard',
    summary: "The owner dashboard's headline figures for an IST day",
    tag: 'analytics',
    access: access.staff,
    query: z.object({ date: CalendarDate }),
    response: DashboardSummary,
  }),
};
