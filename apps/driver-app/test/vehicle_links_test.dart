import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/api.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/core/api/owner_models.dart';
import 'package:taxcy_driver/features/owner/links.dart';
import 'package:taxcy_driver/features/owner/people_screens.dart';
import 'package:taxcy_driver/features/owner/trips/create_trip_screen.dart';
import 'package:taxcy_driver/features/owner/trips/owner_trip_detail_screen.dart';
import 'package:taxcy_driver/features/owner/vehicles_screen.dart';
import 'package:taxcy_driver/features/trips/new_trip_screen.dart';

import 'support/fakes.dart';
import 'support/harness.dart';
import 'support/owner_fakes.dart';

/// Drivers ↔ vehicles links: editing them from either side, setting them up
/// front, and trips only pairing a driver with a vehicle they're linked to.
void main() {
  Future<Harness> setUpOwner(
    WidgetTester tester, {
    String language = 'en',
    double width = 420,
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = Size(width, 2000);
    addTearDown(tester.view.reset);
    final h = await Harness.create(
      session: Session.fromJson(sessionJson(roles: ['owner'])),
      language: language,
    );
    addTearDown(h.dispose);
    return h;
  }

  const createdTripId = '0199c7a2-0000-7000-8000-000000000001';

  /// Opens the dropdown labelled [label] (the last match, in a dialog).
  Future<void> open(WidgetTester tester, String label) async {
    final field = find.ancestor(
      of: find.text(label).last,
      matching: find.byType(DropdownButtonFormField<String?>),
    );
    await tester.ensureVisible(field);
    await tester.tap(field);
    await tester.pumpAndSettle();
  }

  /// Picks a brand and then one of its models from the catalogue dropdowns,
  /// which is how the add-vehicle form fills the make and model.
  Future<void> pick(WidgetTester tester, String key, String option) async {
    final field = find.byKey(Key(key));
    await tester.ensureVisible(field);
    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  group('edit sheets', () {
    testWidgets("a vehicle's drivers are shown and replaced from the sheet", (
      tester,
    ) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(
        h.screen(const VehicleDetailScreen(vehicleId: vehicleId)),
      );
      await settle(tester);
      expect(find.widgetWithText(Chip, 'Ramesh Kumar'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'Suresh Patil'), findsOneWidget);

      await tester.tap(find.byKey(const Key('edit-vehicle-drivers')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Who may drive MH 12 AB 1234?'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('link-$driverId')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('links-save')));
      await settle(tester);
      // Let the sheet finish closing, then the page reload.
      await tester.pump(const Duration(milliseconds: 500));
      await settle(tester);

      expect(h.owner.last('setVehicleDrivers').args, {
        'id': vehicleId,
        'driverIds': [driver2Id],
      });
      expect(find.byType(LinksSheet), findsNothing);
      expect(find.widgetWithText(Chip, 'Ramesh Kumar'), findsNothing);
      expect(find.widgetWithText(Chip, 'Suresh Patil'), findsOneWidget);
    });

    testWidgets('unlinking a driver with trips keeps the sheet open, '
        'saying why', (tester) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(
        h.screen(const VehicleDetailScreen(vehicleId: vehicle2Id)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('edit-vehicle-drivers')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('link-$driver2Id')));
      await tester.pump();
      h.owner.failNext = ApiException(
        status: 409,
        code: 'LINK_IN_USE',
        message: 'In use',
        details: {
          'tripIds': ['t1'],
        },
      );
      await tester.tap(find.byKey(const Key('links-save')));
      await settle(tester);

      expect(find.byType(LinksSheet), findsOneWidget);
      expect(
        find.text(
          'The driver has 1 assigned or running trip in this vehicle. '
          'Reassign or finish it before unlinking.',
        ),
        findsOneWidget,
      );
      expect(h.owner.links[vehicle2Id], {driver2Id});
    });

    testWidgets('a vehicle with no drivers says so', (tester) async {
      final h = await setUpOwner(tester);
      h.owner.links = {};
      await tester.pumpWidget(
        h.screen(const VehicleDetailScreen(vehicleId: vehicleId)),
      );
      await settle(tester);
      expect(find.byKey(const Key('links-none')), findsOneWidget);
    });

    testWidgets("a driver's vehicles are shown and replaced from the sheet", (
      tester,
    ) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(
        h.screen(DriverScreen(driver: Driver.fromJson(driverJson()))),
      );
      await settle(tester);
      // Read from the (reloaded) list: Ramesh drives the first car only.
      expect(find.widgetWithText(Chip, 'MH 12 AB 1234'), findsOneWidget);
      expect(find.widgetWithText(Chip, 'MH 12 CD 5678'), findsNothing);

      await tester.ensureVisible(find.byKey(const Key('edit-driver-vehicles')));
      await tester.tap(find.byKey(const Key('edit-driver-vehicles')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Which vehicles may Ramesh Kumar drive?'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('link-$vehicle2Id')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('links-save')));
      await settle(tester);

      final args = h.owner.last('setDriverVehicles').args;
      expect(args['id'], driverId);
      expect(args['vehicleIds'], unorderedEquals([vehicleId, vehicle2Id]));
      expect(find.widgetWithText(Chip, 'MH 12 CD 5678'), findsOneWidget);
    });
  });

  group('set up front', () {
    testWidgets('adding a vehicle can untick some of its drivers', (
      tester,
    ) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(h.screen(const VehicleFormScreen()));
      await settle(tester);
      await tester.enterText(
        find.byKey(const Key('vehicle-registrationNo')),
        'MH12EF9012',
      );
      await pick(tester, 'vehicle-brand', 'Maruti Suzuki');
      await pick(tester, 'vehicle-model-pick', 'Ertiga');
      await tester.tap(find.byKey(const Key('vehicle-drivers')));
      await tester.pumpAndSettle();
      // Every driver starts ticked; untick Ramesh.
      await tester.tap(find.byKey(const ValueKey('link-$driverId')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('links-save')));
      await tester.pumpAndSettle();
      expect(find.text('Suresh Patil'), findsOneWidget);

      await tester.ensureVisible(find.byKey(const Key('vehicle-save')));
      await tester.tap(find.byKey(const Key('vehicle-save')));
      await settle(tester);
      expect(h.owner.last('createVehicle').args['driverIds'], [driver2Id]);
    });

    testWidgets('adding a vehicle links every active driver by default', (
      tester,
    ) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(h.screen(const VehicleFormScreen()));
      await settle(tester);
      expect(find.text('Ramesh Kumar, Suresh Patil'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('vehicle-registrationNo')),
        'MH12EF9012',
      );
      await pick(tester, 'vehicle-brand', 'Maruti Suzuki');
      await pick(tester, 'vehicle-model-pick', 'Ertiga');
      await tester.ensureVisible(find.byKey(const Key('vehicle-save')));
      await tester.tap(find.byKey(const Key('vehicle-save')));
      await settle(tester);
      expect(
        h.owner.last('createVehicle').args['driverIds'],
        unorderedEquals([driverId, driver2Id]),
      );
    });

    testWidgets('inviting a driver links every active vehicle by default', (
      tester,
    ) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(h.screen(const DriversScreen()));
      await settle(tester);
      await tester.tap(find.byKey(const Key('invite-driver')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('invite-name')), 'Vijay');
      await tester.enterText(
        find.byKey(const Key('invite-phone')),
        '9876543210',
      );
      await tester.tap(find.byKey(const Key('invite-send')));
      await settle(tester);
      expect(
        h.owner.last('inviteDriver').args['vehicleIds'],
        unorderedEquals([vehicleId, vehicle2Id]),
      );
    });

    testWidgets('a vehicle with no drivers yet opens the sheet all ticked', (
      tester,
    ) async {
      final h = await setUpOwner(tester);
      h.owner.links = {vehicleId: {}, vehicle2Id: {}};
      await tester.pumpWidget(
        h.screen(const VehicleDetailScreen(vehicleId: vehicleId)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('edit-vehicle-drivers')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('links-save')));
      await settle(tester);
      await tester.pump(const Duration(milliseconds: 500));
      await settle(tester);
      expect(
        h.owner.last('setVehicleDrivers').args['driverIds'],
        unorderedEquals([driverId, driver2Id]),
      );
    });

    testWidgets('inviting a driver can untick some vehicles', (tester) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(h.screen(const DriversScreen()));
      await settle(tester);
      await tester.tap(find.byKey(const Key('invite-driver')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('invite-name')), 'Vijay');
      await tester.enterText(
        find.byKey(const Key('invite-phone')),
        '9876543210',
      );
      await tester.tap(find.byKey(const Key('invite-vehicles')));
      await tester.pumpAndSettle();
      // Every vehicle starts ticked; untick the first.
      await tester.tap(find.byKey(const ValueKey('link-$vehicleId')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('links-save')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('invite-send')));
      await settle(tester);
      expect(h.owner.last('inviteDriver').args['vehicleIds'], [vehicle2Id]);
    });
  });

  group('trip assignment offers only linked pairs', () {
    testWidgets('a vehicle offers only its drivers', (tester) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(
        h.screen(const OwnerTripDetailScreen(tripId: createdTripId)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('trip-assign')));
      await settle(tester);

      // Ramesh drives only the first car; Suresh drives both.
      await open(tester, 'Vehicle');
      await tester.tap(find.text('MH 12 CD 5678 · Innova Crysta').last);
      await tester.pumpAndSettle();
      await open(tester, 'Driver');
      expect(find.text('Ramesh Kumar'), findsNothing);
      await tester.tap(find.text('Suresh Patil').last);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('assign-confirm')));
      await settle(tester);
      expect(h.owner.last('assign').args['driverId'], driver2Id);
    });

    testWidgets('changing to a vehicle the driver isn\'t linked to clears '
        'the driver', (tester) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(
        h.screen(const OwnerTripDetailScreen(tripId: createdTripId)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('trip-assign')));
      await settle(tester);
      await open(tester, 'Vehicle');
      await tester.tap(find.text('MH 12 AB 1234 · Innova Crysta').last);
      await tester.pumpAndSettle();
      await open(tester, 'Driver');
      await tester.tap(find.text('Ramesh Kumar').last);
      await tester.pumpAndSettle();
      expect(_confirm(tester).onPressed, isNotNull);

      await open(tester, 'MH 12 AB 1234 · Innova Crysta');
      await tester.tap(find.text('MH 12 CD 5678 · Innova Crysta').last);
      await tester.pumpAndSettle();
      expect(find.text('Ramesh Kumar'), findsNothing);
      expect(_confirm(tester).onPressed, isNull);
    });

    testWidgets('a vehicle with no drivers gets a hint', (tester) async {
      final h = await setUpOwner(tester);
      h.owner.links = {
        vehicleId: {driverId},
      };
      await tester.pumpWidget(
        h.screen(const OwnerTripDetailScreen(tripId: createdTripId)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('trip-assign')));
      await settle(tester);
      await open(tester, 'Vehicle');
      await tester.tap(find.text('MH 12 CD 5678 · Innova Crysta').last);
      await tester.pumpAndSettle();
      expect(
        find.text(
          'No drivers are linked to this vehicle. Link drivers on the '
          "vehicle's page first.",
        ),
        findsOneWidget,
      );
      expect(_confirm(tester).onPressed, isNull);
    });

    testWidgets('on a new trip, a driver picked first narrows the vehicles', (
      tester,
    ) async {
      final h = await setUpOwner(tester);
      await tester.pumpWidget(h.screen(const CreateTripScreen()));
      await settle(tester);
      await tester.ensureVisible(find.text('Driver (optional)'));
      await open(tester, 'Driver (optional)');
      await tester.tap(find.text('Ramesh Kumar').last);
      await tester.pumpAndSettle();
      await open(tester, 'Vehicle (optional)');
      expect(find.text('MH 12 CD 5678 · Innova Crysta'), findsNothing);
      await tester.tap(find.text('MH 12 AB 1234 · Innova Crysta').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('owner-trip-from')), 'Pune');
      await tester.enterText(find.byKey(const Key('owner-trip-to')), 'Shirdi');
      await tester.enterText(find.byKey(const Key('owner-trip-fare')), '4500');
      await tester.ensureVisible(find.byKey(const Key('owner-create-trip')));
      await tester.tap(find.byKey(const Key('owner-create-trip')));
      await settle(tester);
      final body = h.owner.last('createTrip').args;
      expect(body['vehicleId'], vehicleId);
      expect(body['driverId'], driverId);
    });

    testWidgets('a driver with no vehicles gets a hint', (tester) async {
      final h = await setUpOwner(tester);
      h.owner.links = {
        vehicleId: {driver2Id},
      };
      await tester.pumpWidget(h.screen(const CreateTripScreen()));
      await settle(tester);
      await tester.ensureVisible(find.text('Driver (optional)'));
      await open(tester, 'Driver (optional)');
      await tester.tap(find.text('Ramesh Kumar').last);
      await tester.pumpAndSettle();
      expect(
        find.text(
          'No vehicles are linked to this driver. Link vehicles on the '
          "driver's page first.",
        ),
        findsOneWidget,
      );
    });
  });

  group('driver mode', () {
    Future<Harness> setUpDriver(WidgetTester tester, String language) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(360, 1600);
      addTearDown(tester.view.reset);
      final h = await Harness.create(
        session: Session.fromJson(sessionJson()),
        language: language,
      );
      addTearDown(h.dispose);
      return h;
    }

    testWidgets('with no linked vehicles, a new trip says to ask the owner', (
      tester,
    ) async {
      final h = await setUpDriver(tester, 'en');
      await tester.pumpWidget(h.screen(const NewTripScreen()));
      await settle(tester);
      expect(
        find.text(
          'No vehicles are linked to you yet. Ask your fleet owner to link '
          'you to a vehicle.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('create-trip')), findsNothing);

      // Once the owner links one, trying again shows the form with it.
      h.api.vehicleList = [Vehicle.fromJson(vehicleJson())];
      await tester.tap(find.byKey(const Key('reload-vehicles')));
      await settle(tester);
      expect(find.byKey(const Key('no-linked-vehicles')), findsNothing);
      expect(find.text('MH12AB1234 · Innova Crysta'), findsOneWidget);
    });

    testWidgets('the picker offers the vehicles the server sent', (
      tester,
    ) async {
      final h = await setUpDriver(tester, 'en');
      h.api.vehicleList = [
        Vehicle.fromJson(vehicleJson()),
        Vehicle.fromJson(vehicleJson(id: vehicle2Id, reg: 'MH12CD5678')),
      ];
      await tester.pumpWidget(h.screen(const NewTripScreen()));
      await settle(tester);
      await tester.tap(find.byKey(const Key('trip-vehicle')));
      await tester.pumpAndSettle();
      expect(find.text('MH12CD5678 · Innova Crysta'), findsOneWidget);
    });

    testWidgets('the empty state is in Hindi too', (tester) async {
      final h = await setUpDriver(tester, 'hi');
      await tester.pumpWidget(h.screen(const NewTripScreen()));
      await settle(tester);
      expect(
        find.text(
          'अभी आपसे कोई गाड़ी नहीं जुड़ी है। फ़्लीट मालिक से कहें कि आपको '
          'किसी गाड़ी से जोड़ दें।',
        ),
        findsOneWidget,
      );
    });
  });

  // The new pieces on a small phone (360 px) in both languages, like
  // screens_smoke_test: any overflow fails the test.
  for (final language in ['en', 'hi']) {
    testWidgets('360 px: edit-drivers sheet ($language)', (tester) async {
      final h = await setUpOwner(tester, language: language, width: 360);
      await tester.pumpWidget(
        h.screen(const VehicleDetailScreen(vehicleId: vehicleId)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('edit-vehicle-drivers')));
      await tester.pumpAndSettle();
      expect(find.byType(LinksSheet), findsOneWidget);
    });

    testWidgets('360 px: edit-vehicles sheet ($language)', (tester) async {
      final h = await setUpOwner(tester, language: language, width: 360);
      await tester.pumpWidget(
        h.screen(DriverScreen(driver: Driver.fromJson(driverJson()))),
      );
      await settle(tester);
      await tester.ensureVisible(find.byKey(const Key('edit-driver-vehicles')));
      await tester.tap(find.byKey(const Key('edit-driver-vehicles')));
      await tester.pumpAndSettle();
      expect(find.byType(LinksSheet), findsOneWidget);
    });

    testWidgets('360 px: invite with vehicles ($language)', (tester) async {
      final h = await setUpOwner(tester, language: language, width: 360);
      await tester.pumpWidget(h.screen(const DriversScreen()));
      await settle(tester);
      await tester.tap(find.byKey(const Key('invite-driver')));
      await settle(tester);
      expect(find.byKey(const Key('invite-vehicles')), findsOneWidget);
    });

    testWidgets('360 px: assign hint ($language)', (tester) async {
      final h = await setUpOwner(tester, language: language, width: 360);
      h.owner.links = {};
      await tester.pumpWidget(
        h.screen(const OwnerTripDetailScreen(tripId: createdTripId)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('trip-assign')));
      await settle(tester);
      await tester.tap(find.byType(DropdownButtonFormField<String?>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('MH 12 CD 5678 · Innova Crysta').last);
      await tester.pumpAndSettle();
    });

    testWidgets('360 px: driver with no vehicles ($language)', (tester) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(360, 1600);
      addTearDown(tester.view.reset);
      final h = await Harness.create(
        session: Session.fromJson(sessionJson()),
        language: language,
      );
      addTearDown(h.dispose);
      await tester.pumpWidget(h.screen(const NewTripScreen()));
      await settle(tester);
      expect(find.byKey(const Key('no-linked-vehicles')), findsOneWidget);
    });
  }
}

FilledButton _confirm(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(const Key('assign-confirm')));
