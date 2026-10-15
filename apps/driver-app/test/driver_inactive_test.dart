import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/api.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/core/api/owner_models.dart';
import 'package:taxcy_driver/features/owner/owner_text.dart';
import 'package:taxcy_driver/features/owner/people_screens.dart';
import 'package:taxcy_driver/features/owner/trips/owner_trips_screen.dart';
import 'package:taxcy_driver/features/trips/trips_screen.dart';

import 'support/fakes.dart';
import 'support/harness.dart';
import 'support/owner_fakes.dart';

Future<Harness> tall(
  WidgetTester tester, {
  List<String> roles = const ['owner'],
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(420, 2400);
  addTearDown(tester.view.reset);
  final h = await Harness.create(
    session: Session.fromJson(sessionJson(roles: roles)),
  );
  addTearDown(h.dispose);
  return h;
}

/// Opens the driver's page, picks "Inactive" and saves.
Future<void> markInactive(WidgetTester tester, Harness h) async {
  await tester.pumpWidget(
    h.screen(DriverScreen(driver: Driver.fromJson(driverJson()))),
  );
  await settle(tester);
  await tester.tap(find.byKey(const Key('driver-status')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Inactive (can’t be assigned)').last);
  await tester.pumpAndSettle();
  final save = find.byKey(const Key('driver-save'));
  await tester.ensureVisible(save);
  await tester.tap(save);
  await tester.pumpAndSettle();
}

List<ApiCall> updates(Harness h) =>
    h.owner.calls.where((c) => c.name == 'updateDriver').toList();

void main() {
  group('vehicle name next to the number', () {
    test('vehicleLabel', () {
      const v = TripVehicle(
        id: 'v',
        registrationNo: 'MH12CD5678',
        model: 'Swift Dzire',
      );
      expect(vehicleLabel(v), 'MH 12 CD 5678 · Swift Dzire');
      expect(
        vehicleLabel(
          const TripVehicle(id: 'v', registrationNo: 'MH12CD5678', model: ' '),
        ),
        'MH 12 CD 5678',
      );
    });

    testWidgets('the owner trips list shows the model', (tester) async {
      final h = await tall(tester);
      const id = '0199c7a2-0000-7000-8000-0000000000e9';
      h.owner.tripsById[id] = tripJson(id: id, status: 'assigned');
      await tester.pumpWidget(h.screen(const OwnerTripsScreen()));
      await settle(tester);
      expect(find.textContaining('Innova Crysta'), findsWidgets);
    });
  });

  group('marking a driver inactive', () {
    testWidgets('with booked trips: lists them, unassigns them on confirm', (
      tester,
    ) async {
      final h = await tall(tester);
      h.owner.updateDriverErrors.add(
        ApiException(
          status: 409,
          code: 'DRIVER_HAS_TRIPS',
          message: 'has trips',
          details: {
            'trips': [
              {
                'id': 't1',
                'from': 'Pune Airport',
                'to': 'Nashik Road',
                'scheduledStartAt': '2026-10-20T05:30:00.000Z',
                'registrationNo': 'MH12CD5678',
              },
            ],
          },
        ),
      );
      await markInactive(tester, h);
      expect(find.byKey(const Key('driver-has-trips-dialog')), findsOneWidget);
      expect(find.text('Ramesh Kumar has 1 upcoming trip'), findsOneWidget);
      expect(find.textContaining('Pune Airport → Nashik Road'), findsOneWidget);
      expect(find.textContaining('MH 12 CD 5678'), findsOneWidget);

      await tester.tap(find.byKey(const Key('driver-unassign-and-deactivate')));
      await settle(tester);
      final calls = updates(h);
      expect(calls, hasLength(2));
      expect(calls.first.args['unassignTrips'], isFalse);
      expect(calls.last.args, containsPair('unassignTrips', true));
      expect(calls.last.args, containsPair('status', 'inactive'));
      expect(find.byKey(const Key('action-error')), findsNothing);
    });

    testWidgets('cancelling the dialog changes nothing', (tester) async {
      final h = await tall(tester);
      h.owner.updateDriverErrors.add(
        ApiException(
          status: 409,
          code: 'DRIVER_HAS_TRIPS',
          message: 'has trips',
          details: {'trips': <Object>[]},
        ),
      );
      await markInactive(tester, h);
      await tester.tap(find.byKey(const Key('driver-has-trips-cancel')));
      await settle(tester);
      expect(updates(h), hasLength(1));
      expect(find.byType(DriverScreen), findsOneWidget);
    });

    testWidgets('while on a trip: explains and stays', (tester) async {
      final h = await tall(tester);
      h.owner.updateDriverErrors.add(
        ApiException(status: 409, code: 'DRIVER_ON_TRIP', message: 'on trip'),
      );
      await markInactive(tester, h);
      expect(find.byKey(const Key('driver-on-trip-dialog')), findsOneWidget);
      expect(find.text('Ramesh Kumar is on a trip right now'), findsOneWidget);
      expect(updates(h), hasLength(1));
    });
  });

  testWidgets("an inactive driver's card is red", (tester) async {
    final h = await tall(tester);
    h.owner.driverList = [
      driverJson(),
      {
        ...driverJson(id: driver2Id, name: 'Suresh Patil'),
        'status': 'inactive',
      },
    ];
    await tester.pumpWidget(h.screen(const DriversScreen()));
    await settle(tester);
    final active = tester.widget<Card>(
      find.byKey(const ValueKey('driver-card-$driverId')),
    );
    final inactive = tester.widget<Card>(
      find.byKey(const ValueKey('driver-card-$driver2Id')),
    );
    expect(active.color, isNull);
    expect(inactive.color, Colors.red.shade50);
  });

  testWidgets('an inactive driver sees why and cannot create trips', (
    tester,
  ) async {
    final h = await tall(tester, roles: ['driver']);
    h.me.driverJsonValue = {...h.me.driverJsonValue, 'status': 'inactive'};
    await tester.pumpWidget(h.screen(const TripsScreen()));
    await settle(tester);
    expect(find.byKey(const Key('driver-inactive-banner')), findsOneWidget);
    await tester.tap(find.byKey(const Key('driver-action-new-trip')));
    await settle(tester);
    expect(
      find.text('New trip'),
      findsOneWidget,
    ); // still on home, not the form
    expect(
      tester
          .widget<InkWell>(find.byKey(const Key('driver-action-new-trip')))
          .onTap,
      isNull,
    );
  });

  testWidgets('an active driver has no banner', (tester) async {
    final h = await tall(tester, roles: ['driver']);
    await tester.pumpWidget(h.screen(const TripsScreen()));
    await settle(tester);
    expect(find.byKey(const Key('driver-inactive-banner')), findsNothing);
    expect(
      tester
          .widget<InkWell>(find.byKey(const Key('driver-action-new-trip')))
          .onTap,
      isNotNull,
    );
  });
}
