import type { AlertText } from '../messages.js';
import { IST_TIME_ZONE } from '../time.js';

/**
 * A trip still waiting for a vehicle and driver turns critical this close to its
 * scheduled start, and stays critical once the start has passed.
 */
export const UNASSIGNED_CRITICAL_BEFORE_MS = 2 * 3_600_000;

export interface UnassignedTrip {
  from: string;
  to: string | null;
  scheduledStartAt: Date;
}

/** Warning while there's time to assign; critical within two hours of the start. */
export function unassignedTripSeverity(scheduledStartAt: Date, now: Date): 'warning' | 'critical' {
  return scheduledStartAt.getTime() - now.getTime() <= UNASSIGNED_CRITICAL_BEFORE_MS
    ? 'critical'
    : 'warning';
}

const startFormat = new Intl.DateTimeFormat('en-IN', {
  timeZone: IST_TIME_ZONE,
  day: 'numeric',
  month: 'short',
  hour: 'numeric',
  minute: '2-digit',
  hour12: true,
});

/** The alert for a trip that has no vehicle or driver yet. */
export function explainUnassignedTrip(trip: UnassignedTrip, now: Date): AlertText {
  const route = trip.to === null ? trip.from : `${trip.from} → ${trip.to}`;
  const when = startFormat.format(trip.scheduledStartAt);
  const overdue = trip.scheduledStartAt.getTime() <= now.getTime();
  return {
    message: {
      key: 'trip_unassigned',
      params: {
        from: trip.from,
        to: trip.to,
        scheduledStartAt: trip.scheduledStartAt.toISOString(),
        overdue,
      },
    },
    title: `Trip ${route} has no vehicle or driver yet`,
    explanation: overdue
      ? `It was due to start at ${when} IST and still has no vehicle or driver. Assign one, or cancel the trip.`
      : `It starts at ${when} IST. Assign a vehicle and driver before then.`,
  };
}
