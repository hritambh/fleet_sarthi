import type { RouteDef } from '../http.js';
import { analyticsRoutes } from './analytics.js';
import { fleetRoutes } from './fleet.js';
import { fuelRoutes } from './fuel.js';
import { healthRoutes } from './health.js';
import { identityRoutes, memberRoutes } from './identity.js';
import { mediaRoutes } from './media.js';
import { alertRoutes, moneyRoutes } from './money.js';
import { telemetryRoutes } from './telemetry.js';
import { tripRoutes } from './trips.js';

export * from './analytics.js';
export * from './fleet.js';
export * from './fuel.js';
export { healthRoutes } from './health.js';
export * from './identity.js';
export * from './media.js';
export * from './money.js';
export * from './telemetry.js';
export * from './trips.js';

const groups: readonly Record<string, RouteDef>[] = [
  healthRoutes,
  identityRoutes,
  memberRoutes,
  mediaRoutes,
  fleetRoutes,
  tripRoutes,
  fuelRoutes,
  telemetryRoutes,
  moneyRoutes,
  alertRoutes,
  analyticsRoutes,
];

/** Every API route. The API asserts at startup that each has exactly one handler. */
export const allRoutes: readonly RouteDef[] = groups.flatMap((g) => Object.values(g));
