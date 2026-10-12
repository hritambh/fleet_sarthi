import '../../core/repositories/trips_repository.dart';

/// A driver's numbers for a stretch of days.
class DriverStats {
  const DriverStats({
    this.tripsDone = 0,
    this.tripsTotal = 0,
    this.km = 0,
    this.collectedPaise = 0,
    this.cashPaise = 0,
  });

  /// Trips ended (or settled) in the period.
  final int tripsDone;

  /// Trips that belong to the period: ended in it, scheduled in it, or under
  /// way. Cancelled ones don't count.
  final int tripsTotal;

  /// Odometer km of the trips ended in the period.
  final int km;

  /// Money collected in the period, and the cash part of it.
  final int collectedPaise;
  final int cashPaise;
}

/// What the driver's home shows, worked out from the trips on the phone (so it
/// works offline).
class DriverSummary {
  const DriverSummary({
    required this.today,
    required this.week,
    this.onTheRoad,
    this.next,
  });

  /// The trip under way, if any.
  final TripView? onTheRoad;

  /// The earliest assigned trip not started yet (it may be overdue).
  final TripView? next;

  final DriverStats today;

  /// The last 7 days, today included.
  final DriverStats week;
}

DriverSummary summariseDriverDay(List<TripView> trips, {DateTime? now}) {
  final at = (now ?? DateTime.now()).toLocal();
  final startOfToday = DateTime(at.year, at.month, at.day);
  final endOfToday = startOfToday.add(const Duration(days: 1));
  final startOfWeek = startOfToday.subtract(const Duration(days: 6));

  TripView? onTheRoad;
  TripView? next;
  for (final view in trips) {
    final t = view.trip;
    if (t.status == 'started') onTheRoad ??= view;
    if (t.status == 'assigned' &&
        (next == null ||
            t.scheduledStartAt.isBefore(next.trip.scheduledStartAt))) {
      next = view;
    }
  }

  DriverStats stats(DateTime from, DateTime to) {
    bool within(DateTime? when) {
      if (when == null) return false;
      final local = when.toLocal();
      return !local.isBefore(from) && local.isBefore(to);
    }

    var done = 0;
    var total = 0;
    var km = 0;
    var collected = 0;
    var cash = 0;
    for (final view in trips) {
      final t = view.trip;
      if (t.status == 'cancelled') continue;
      final ended = t.status == 'ended' || t.status == 'settled';
      final endedHere = ended && within(t.endedAt ?? t.scheduledStartAt);
      if (endedHere) {
        done++;
        km += t.drivenKm ?? 0;
      }
      if (endedHere ||
          t.status == 'started' ||
          (!ended && within(t.scheduledStartAt))) {
        total++;
      }
      for (final c in t.collections) {
        if (!within(c.collectedAt ?? t.endedAt ?? t.scheduledStartAt)) {
          continue;
        }
        collected += c.amountPaise;
        if (c.method == 'cash') cash += c.amountPaise;
      }
    }
    return DriverStats(
      tripsDone: done,
      tripsTotal: total,
      km: km,
      collectedPaise: collected,
      cashPaise: cash,
    );
  }

  return DriverSummary(
    onTheRoad: onTheRoad,
    next: next,
    today: stats(startOfToday, endOfToday),
    week: stats(startOfWeek, endOfToday),
  );
}
