import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/owner/trips/owner_trip_detail_screen.dart';
import 'package:taxcy_driver/features/trips/trip_detail_screen.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

const tripId = 'a0000000-0000-4000-8000-000000000021';
const startPhoto = '0199c7a2-0000-7000-8000-0000000000c1';
const pumpPhoto = '0199c7a2-0000-7000-8000-0000000000c7';
const receiptPhoto = '0199c7a2-0000-7000-8000-0000000000c8';

/// A trip on the road with one fuel fill and its two photos.
Map<String, Object?> tripWithFuel() => {
  ...tripJson(id: tripId, status: 'started'),
  'fuelFills': [
    {
      'id': '0199c7a2-0000-7000-8000-0000000000f7',
      'fuel': 'petrol',
      'quantityMilli': 30000,
      'costPaise': 300000,
      'paidBy': 'driver_cash',
      'isFullTank': true,
      'filledAt': '2026-10-09T06:00:00.000Z',
      'odometerMediaId': pumpPhoto,
      'receiptMediaId': receiptPhoto,
    },
  ],
};

void main() {
  testWidgets('the driver sees the trip’s odometer and fuel photos', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(420, 2400);
    addTearDown(tester.view.reset);
    final h = await Harness.create();
    addTearDown(h.dispose);
    await h.engine.cacheTrip(Trip.fromJson(tripWithFuel()));
    await tester.pumpWidget(h.screen(const TripDetailScreen(tripId: tripId)));
    await settle(tester);

    expect(find.byKey(const Key('trip-photos')), findsOneWidget);
    for (final id in [startPhoto, pumpPhoto, receiptPhoto]) {
      expect(find.byKey(ValueKey('trip-photo-$id')), findsOneWidget);
    }
    expect(find.textContaining('Receipt photo'), findsOneWidget);
  });

  testWidgets('the owner sees each fuel fill with its photos', (tester) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(420, 2400);
    addTearDown(tester.view.reset);
    final h = await Harness.create(
      session: Session.fromJson(sessionJson(roles: ['owner'])),
    );
    addTearDown(h.dispose);
    h.owner.tripsById[tripId] = tripWithFuel();
    await tester.pumpWidget(
      h.screen(const OwnerTripDetailScreen(tripId: tripId)),
    );
    await settle(tester);

    final fuel = find.byKey(const Key('owner-trip-fuel'));
    await tester.ensureVisible(fuel);
    expect(fuel, findsOneWidget);
    for (final id in [pumpPhoto, receiptPhoto]) {
      expect(
        find.descendant(
          of: fuel,
          matching: find.byKey(ValueKey('trip-photo-$id')),
        ),
        findsOneWidget,
      );
    }
  });
}
