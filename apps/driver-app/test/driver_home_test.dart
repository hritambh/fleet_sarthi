import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/core/repositories/trips_repository.dart';
import 'package:taxcy_driver/features/trips/driver_summary.dart';
import 'package:taxcy_driver/features/trips/trips_screen.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

/// An ended trip: [km] driven, [collections] as (method, paise).
TripView ended(
  String id, {
  required DateTime endedAt,
  int km = 100,
  List<(String, int)> collections = const [],
}) {
  final json = tripJson(id: id, status: 'ended', scheduledStartAt: endedAt)
    ..['endedAt'] = endedAt.toUtc().toIso8601String()
    ..['startOdometer'] = odometer('b1', 48000)
    ..['endOdometer'] = odometer('b2', 48000 + km)
    ..['collections'] = [
      for (final (i, (method, paise)) in collections.indexed)
        {
          'id': '0199c7a2-0000-7000-8000-00000000c0${i}0',
          'method': method,
          'amountPaise': paise,
          'reference': null,
          'collectedAt': endedAt.toUtc().toIso8601String(),
        },
    ];
  return TripView(Trip.fromJson(json));
}

Map<String, Object?> odometer(String suffix, int km) => {
  'id': '0199c7a2-0000-7000-8000-0000000000$suffix',
  'typedKm': km,
  'ocrKm': null,
  'mediaId': '0199c7a2-0000-7000-8000-0000000000c1',
  'capturedAt': '2026-10-09T03:00:00.000Z',
};

TripView trip(String id, String status, DateTime start) => TripView(
  Trip.fromJson(tripJson(id: id, status: status, scheduledStartAt: start)),
);

void main() {
  final now = DateTime(2026, 10, 13, 15);

  group('summariseDriverDay', () {
    test('finds the trip on the road and the earliest assigned one', () {
      final s = summariseDriverDay([
        trip('a1', 'assigned', now.add(const Duration(days: 2))),
        trip('a2', 'started', now.subtract(const Duration(hours: 1))),
        // Overdue still counts as next: the driver hasn't started it.
        trip('a3', 'assigned', now.subtract(const Duration(minutes: 20))),
        trip('a4', 'cancelled', now.subtract(const Duration(hours: 2))),
      ], now: now);
      expect(s.onTheRoad?.trip.id, 'a2');
      expect(s.next?.trip.id, 'a3');
    });

    test('adds up today and the last 7 days', () {
      final s = summariseDriverDay([
        ended(
          'e1',
          endedAt: now.subtract(const Duration(hours: 2)),
          km: 120,
          collections: [('cash', 200000), ('upi', 150000)],
        ),
        ended(
          'e2',
          endedAt: now.subtract(const Duration(days: 3)),
          km: 80,
          collections: [('cash', 100000)],
        ),
        // Eight days ago: outside the week.
        ended(
          'e3',
          endedAt: now.subtract(const Duration(days: 8)),
          collections: [('cash', 999900)],
        ),
        trip('a1', 'started', now.subtract(const Duration(hours: 1))),
        trip('a2', 'assigned', now.add(const Duration(hours: 3))),
        trip('a3', 'cancelled', now.add(const Duration(hours: 4))),
      ], now: now);

      expect(s.today.tripsDone, 1);
      expect(s.today.tripsTotal, 3); // ended, on the road, later today
      expect(s.today.km, 120);
      expect(s.today.collectedPaise, 350000);
      expect(s.today.cashPaise, 200000);

      expect(s.week.tripsDone, 2);
      expect(s.week.km, 200);
      expect(s.week.collectedPaise, 450000);
      expect(s.week.cashPaise, 300000);
    });

    test('is empty with no trips', () {
      final s = summariseDriverDay(const [], now: now);
      expect(s.onTheRoad, isNull);
      expect(s.next, isNull);
      expect(s.today.tripsTotal, 0);
      expect(s.week.collectedPaise, 0);
    });
  });

  testWidgets('a driver with no trips sees a friendly empty state', (
    tester,
  ) async {
    final h = await Harness.create();
    addTearDown(h.dispose);
    await tester.pumpWidget(h.screen(const TripsScreen()));
    await settle(tester);
    expect(find.text('No trips assigned yet'), findsOneWidget);
    expect(find.text('Today at a glance'), findsOneWidget);
    expect(find.text('Trip in progress'), findsNothing);
    expect(find.text('Next trip'), findsNothing);
  });
}
