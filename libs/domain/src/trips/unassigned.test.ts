import { describe, expect, it } from 'vitest';
import { explainUnassignedTrip, unassignedTripSeverity } from './unassigned.js';

// 16 Oct 2026, 10:00 IST.
const start = new Date('2026-10-16T04:30:00Z');
const hours = (h: number) => new Date(start.getTime() - h * 3_600_000);

describe('unassignedTripSeverity', () => {
  it.each([
    [48, 'warning'],
    [2.5, 'warning'],
    [2, 'critical'], // exactly two hours before
    [0.5, 'critical'],
    [-3, 'critical'], // the start has passed
  ])('%f hours before the start → %s', (before, severity) => {
    expect(unassignedTripSeverity(start, hours(before))).toBe(severity);
  });
});

describe('explainUnassignedTrip', () => {
  const trip = { from: 'Pune Station', to: 'Goa (Panaji)', scheduledStartAt: start };

  it('says when the trip starts, in IST', () => {
    const text = explainUnassignedTrip(trip, hours(24));
    expect(text.title).toBe('Trip Pune Station → Goa (Panaji) has no vehicle or driver yet');
    expect(text.explanation).toBe(
      'It starts at 16 Oct, 10:00 am IST. Assign a vehicle and driver before then.',
    );
    expect(text.message).toEqual({
      key: 'trip_unassigned',
      params: {
        from: 'Pune Station',
        to: 'Goa (Panaji)',
        scheduledStartAt: '2026-10-16T04:30:00.000Z',
        overdue: false,
      },
    });
  });

  it('once the start has passed, says so', () => {
    const text = explainUnassignedTrip(trip, hours(-1));
    expect(text.explanation).toBe(
      'It was due to start at 16 Oct, 10:00 am IST and still has no vehicle or driver. ' +
        'Assign one, or cancel the trip.',
    );
    expect(text.message.params).toMatchObject({ overdue: true });
  });

  it('a local rental has no drop', () => {
    const text = explainUnassignedTrip({ ...trip, to: null }, hours(24));
    expect(text.title).toBe('Trip Pune Station has no vehicle or driver yet');
  });
});
