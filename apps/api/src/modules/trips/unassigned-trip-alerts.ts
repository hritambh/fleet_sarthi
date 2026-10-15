import { Injectable, Logger } from '@nestjs/common';
import type { TenantTx } from '@taxcy/db';
import { explainUnassignedTrip, unassignedTripSeverity } from '@taxcy/domain';
import { OnJob } from '../../platform/jobs/on-job.js';
import { Db } from '../../platform/prisma.service.js';
import { AlertsRepository } from '../alerts/alerts.repository.js';

/**
 * "This trip has no vehicle or driver yet": one alert per trip still waiting
 * for an assignment (status created), raised as soon as it's created or
 * unassigned and resolved once it's assigned or cancelled. A scan every 15
 * minutes raises the severity as the start nears (critical within two hours)
 * and catches trips created before this alert existed.
 */
@Injectable()
export class UnassignedTripAlerts {
  private readonly logger = new Logger('UnassignedTripAlerts');

  constructor(
    private readonly db: Db,
    private readonly alerts: AlertsRepository,
  ) {}

  /** Every alert for the trip starts with this key. */
  static keyPrefix(tripId: string): string {
    return `trip_unassigned:${tripId}`;
  }

  /**
   * Raises, updates or resolves the trip's alert to match its current state.
   *
   * Each spell of waiting has its own alert (the key counts the trip's
   * unassignments), so a trip unassigned after its alert resolved gets a new
   * one, while an alert the owner dismissed stays dismissed for that spell.
   */
  async sync(tx: TenantTx, tripId: string, now = new Date()): Promise<void> {
    const trip = await tx.trip.findFirst({
      where: { id: tripId, orgId: tx.orgId },
      select: { id: true, status: true, fromText: true, toText: true, scheduledStartAt: true },
    });
    const prefix = UnassignedTripAlerts.keyPrefix(tripId);
    if (trip?.status !== 'created') {
      await this.alerts.autoResolvePrefix(tx, prefix);
      return;
    }
    const unassignments = await tx.tripEvent.count({
      where: { tripId, eventType: 'trip.unassigned' },
    });
    const key = unassignments === 0 ? prefix : `${prefix}:${unassignments}`;
    await this.alerts.autoResolvePrefix(tx, prefix, key);
    const text = explainUnassignedTrip(
      { from: trip.fromText, to: trip.toText, scheduledStartAt: trip.scheduledStartAt },
      now,
    );
    await this.alerts.raise(tx, {
      kind: 'trip_unassigned',
      severity: unassignedTripSeverity(trip.scheduledStartAt, now),
      ...text,
      subjectType: 'trip',
      subjectId: trip.id,
      tripId: trip.id,
      dedupeKey: key,
    });
  }

  @OnJob('trip.unassigned_scan')
  async scan(): Promise<void> {
    const now = new Date();
    const orgs = await this.db.system((tx) => tx.organization.findMany({ select: { id: true } }));
    let checked = 0;
    for (const org of orgs) {
      checked += await this.db.tenant(org.id, async (tx) => {
        // Every trip still waiting, plus every trip with an open alert (which
        // may since have been assigned or cancelled).
        const waiting = await tx.trip.findMany({
          where: { orgId: org.id, status: 'created' },
          select: { id: true },
        });
        const alerted = await tx.alert.findMany({
          where: {
            orgId: org.id,
            kind: 'trip_unassigned',
            status: { in: ['open', 'acknowledged'] },
          },
          select: { tripId: true },
        });
        const ids = new Set([
          ...waiting.map((t) => t.id),
          ...alerted.flatMap((a) => (a.tripId ? [a.tripId] : [])),
        ]);
        for (const id of ids) await this.sync(tx, id, now);
        return ids.size;
      });
    }
    this.logger.log(`unassigned trip scan: ${checked} trips across ${orgs.length} orgs`);
  }
}
