import { z } from 'zod';
import { Id, Paise } from '../common.js';
import { access, defineRoute } from '../http.js';
import { FuelType } from './fleet.js';

/** Fuel is measured in litres, except CNG which is weighed in kilograms. */
export const FuelUnit = z.enum(['L', 'kg']);
export type FuelUnit = z.infer<typeof FuelUnit>;

export const AnalyticsVehicle = z.object({
  id: Id,
  registrationNo: z.string(),
  make: z.string(),
  model: z.string(),
  fuelType: FuelType,
});
export type AnalyticsVehicle = z.infer<typeof AnalyticsVehicle>;

/**
 * Every series below is index-aligned with `days`, so a chart can read a vehicle's
 * value for day i without a lookup. Days with nothing recorded are 0, not a gap;
 * an average with no trips to divide by is null so charts can break the line.
 */
export const MonthlyAnalytics = z.object({
  year: z.number().int(),
  /** 1-12. */
  month: z.number().int(),
  /** IST calendar days in the month, up to today when the month is still running. */
  days: z.array(z.iso.date()),
  vehicles: z.array(AnalyticsVehicle),
  /**
   * Fuel put into each vehicle per day. The unit comes from the fill, not the vehicle,
   * so a bifuel (petrol + CNG) vehicle has one row per unit it was actually filled with.
   * Only vehicles filled during the month appear here.
   */
  fuel: z.array(
    z.object({
      vehicleId: Id,
      unit: FuelUnit,
      quantity: z.array(z.number()),
      costPaise: z.array(Paise),
    }),
  ),
  /** What each vehicle earned per day: billed to the customer, and actually collected. */
  revenue: z.array(
    z.object({
      vehicleId: Id,
      billedPaise: z.array(Paise),
      collectedPaise: z.array(Paise),
    }),
  ),
  /** Distance each vehicle covered per day, from its trip odometer readings. */
  distance: z.array(z.object({ vehicleId: Id, km: z.array(z.number()) })),
  /** All vehicles summed, per day. */
  distanceTotalKm: z.array(z.number()),
  /** Fleet-wide averages per trip, per day. Null where there were no trips. */
  perTrip: z.object({
    trips: z.array(z.number().int()),
    activeVehicles: z.array(z.number().int()),
    revenuePerTripPaise: z.array(z.number().nullable()),
    kmPerTrip: z.array(z.number().nullable()),
    fuelCostPerTripPaise: z.array(z.number().nullable()),
    tripsPerVehicle: z.array(z.number().nullable()),
  }),
});
export type MonthlyAnalytics = z.infer<typeof MonthlyAnalytics>;

export const analyticsRoutes = {
  monthly: defineRoute({
    method: 'GET',
    path: '/analytics/monthly',
    summary: 'Daily fuel, revenue, distance and per-trip averages for one IST month',
    tag: 'analytics',
    access: access.staff,
    query: z.object({
      year: z.coerce.number().int().min(2000).max(2100),
      month: z.coerce.number().int().min(1).max(12),
    }),
    response: MonthlyAnalytics,
  }),
};
