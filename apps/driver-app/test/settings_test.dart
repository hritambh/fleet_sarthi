import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/fuel/fuel_fill_screen.dart';
import 'package:taxcy_driver/features/owner/settings/settings_pages.dart';
import 'package:taxcy_driver/features/owner/settings_screen.dart';
import 'package:taxcy_driver/features/trips/trip_forms.dart';
import 'package:taxcy_driver/features/trips/trips_screen.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

const _orgId = '0199c7a2-0000-7000-8000-000000000999';

Future<Harness> signedIn(
  WidgetTester tester, {
  List<String> roles = const ['owner'],
  String language = 'en',
  double width = 420,
  Map<String, Object> preferences = const {},
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = Size(width, 2400);
  addTearDown(tester.view.reset);
  final h = await Harness.create(
    session: Session.fromJson(sessionJson(roles: roles)),
    language: language,
    preferences: preferences,
  );
  addTearDown(h.dispose);
  return h;
}

Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(find.byKey(Key(key)));
  await tester.tap(find.byKey(Key(key)));
  await settle(tester);
}

void main() {
  group('the hub', () {
    // Each category opens its page; a layout overflow anywhere fails the test.
    for (final language in ['en', 'hi', 'kn', 'mr']) {
      testWidgets('every page opens on a 360 px phone ($language)', (
        tester,
      ) async {
        final h = await signedIn(tester, language: language, width: 360);
        await tester.pumpWidget(h.screen(const SettingsScreen()));
        await settle(tester);
        for (final page in [
          'settings-general',
          'settings-trips',
          'settings-fuel',
          'settings-reminders',
          'settings-pay',
          'settings-team',
        ]) {
          await tapKey(tester, page);
          await tester.pumpAndSettle();
          expect(find.byType(BackButton), findsOneWidget, reason: page);
          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();
        }
      });
    }

    testWidgets('managers are told settings are the owner\'s', (tester) async {
      final h = await signedIn(tester, roles: ['manager']);
      await tester.pumpWidget(h.screen(const SettingsScreen()));
      await settle(tester);
      expect(find.byKey(const Key('settings-owner-only')), findsOneWidget);
    });
  });

  group('trips & drivers', () {
    testWidgets('turning a rule off is saved; nothing is sent until Save', (
      tester,
    ) async {
      final h = await signedIn(tester);
      await tester.pumpWidget(h.screen(const TripRulesScreen()));
      await settle(tester);
      expect(find.byKey(const Key('settings-unsaved')), findsNothing);
      // Every setting says what it affects and when.
      expect(find.text('Affects: driver app: New trip'), findsOneWidget);

      await tester.tap(find.byKey(const Key('rule-driver-trips')));
      await tester.pump();
      expect(find.byKey(const Key('settings-unsaved')), findsOneWidget);
      expect(h.owner.names, isNot(contains('updateWorkflowSettings')));

      await tapKey(tester, 'settings-save');
      expect(h.owner.last('updateWorkflowSettings').args, {
        'driversCanCreateTrips': false,
        'driversCanAddCharges': true,
        'fuelReceiptRequired': true,
      });
      // The tolerance didn't change, so it isn't sent.
      expect(h.owner.names, isNot(contains('updateAuditSettings')));
      expect(find.text('Saved.'), findsOneWidget);
      expect(find.byKey(const Key('settings-unsaved')), findsNothing);
    });

    testWidgets('Cancel puts back what is saved', (tester) async {
      final h = await signedIn(tester);
      await tester.pumpWidget(h.screen(const TripRulesScreen()));
      await settle(tester);
      await tester.tap(find.byKey(const Key('rule-driver-charges')));
      await tester.pump();
      await tapKey(tester, 'settings-cancel');
      final charges = tester.widget<Switch>(
        find.byKey(const Key('rule-driver-charges')),
      );
      expect(charges.value, isTrue);
      expect(find.byKey(const Key('settings-unsaved')), findsNothing);
    });

    testWidgets('leaving with unsaved changes asks first', (tester) async {
      final h = await signedIn(tester);
      await tester.pumpWidget(h.screen(const SettingsScreen()));
      await settle(tester);
      await tapKey(tester, 'settings-trips');
      await tester.tap(find.byKey(const Key('rule-driver-trips')));
      await tester.pump();

      await tester.tap(find.byType(BackButton));
      await settle(tester);
      expect(find.byKey(const Key('settings-discard-dialog')), findsOneWidget);
      await tapKey(tester, 'settings-keep-editing');
      expect(find.byKey(const Key('rule-driver-trips')), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await settle(tester);
      await tapKey(tester, 'settings-discard');
      // Back on the hub, nothing saved.
      expect(find.byKey(const Key('settings-trips')), findsOneWidget);
      expect(h.owner.names, isNot(contains('updateWorkflowSettings')));
    });
  });

  group('fuel audit', () {
    testWidgets(
      'a value out of range is flagged beside the field; Save is off',
      (tester) async {
        final h = await signedIn(tester);
        await tester.pumpWidget(h.screen(const FuelRulesScreen()));
        await settle(tester);
        await tester.enterText(find.byKey(const Key('audit-k')), '9');
        await tester.pump();
        expect(find.text('Enter a number from 0.5 to 5.'), findsOneWidget);
        final save = tester.widget<FilledButton>(
          find.byKey(const Key('settings-save')),
        );
        expect(save.onPressed, isNull);
      },
    );

    testWidgets('reset to defaults fills the form; Save applies it', (
      tester,
    ) async {
      final h = await signedIn(tester);
      await tester.pumpWidget(h.screen(const FuelRulesScreen()));
      await settle(tester);
      // The fake fleet has 5 cycles and 15%; a new fleet has 3 and 20%.
      await tapKey(tester, 'settings-reset');
      expect(h.owner.names, isNot(contains('updateAuditSettings')));
      await tapKey(tester, 'settings-save');
      expect(
        h.owner.last('updateAuditSettings').args,
        containsPair('fuelMinCycles', 3),
      );
      expect(
        h.owner.last('updateAuditSettings').args,
        containsPair('fuelPctThreshold', 20.0),
      );
    });
  });

  testWidgets('reminder days must be up to five numbers', (tester) async {
    final h = await signedIn(tester);
    await tester.pumpWidget(h.screen(const RemindersScreen()));
    await settle(tester);
    await tester.enterText(find.byKey(const Key('audit-days')), '30, x');
    await tester.pump();
    expect(
      find.text('Up to 5 whole numbers from 0 to 365, e.g. 30, 7, 1.'),
      findsOneWidget,
    );
    await tester.enterText(find.byKey(const Key('audit-days')), '15, 3');
    await tester.pump();
    await tapKey(tester, 'settings-save');
    expect(h.owner.last('updateAuditSettings').args['docAlertDays'], [15, 3]);
  });

  group('general', () {
    testWidgets('the owner renames the fleet; the fleets list is reloaded', (
      tester,
    ) async {
      final h = await signedIn(tester);
      await tester.pumpWidget(h.screen(const GeneralSettingsScreen()));
      await settle(tester);
      expect(find.text('Sharma Travels'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('settings-fleet-name')), 'S');
      await tester.pump();
      expect(find.text('Use 2 to 100 characters.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('settings-fleet-name')),
        'Sharma Tours',
      );
      await tester.pump();
      await tapKey(tester, 'settings-save');
      expect(h.owner.last('renameOrg').args, {'name': 'Sharma Tours'});
      expect(h.auth.names, contains('memberships'));
      expect(find.text('Saved.'), findsOneWidget);
    });

    testWidgets('a manager sees the name but can\'t change it', (tester) async {
      final h = await signedIn(tester, roles: ['manager']);
      await tester.pumpWidget(h.screen(const GeneralSettingsScreen()));
      await settle(tester);
      final field = tester.widget<TextField>(
        find.byKey(const Key('settings-fleet-name')),
      );
      expect(field.enabled, isFalse);
      expect(find.byKey(const Key('settings-save')), findsNothing);
    });
  });

  group('in the driver app', () {
    const off = WorkflowSettings(
      driversCanCreateTrips: false,
      driversCanAddCharges: false,
      fuelReceiptRequired: false,
    );

    testWidgets('New trip is off when the owner turned it off, and says why', (
      tester,
    ) async {
      final h = await signedIn(tester, roles: ['driver']);
      h.api.workflow = off;
      await tester.pumpWidget(h.screen(const TripsScreen()));
      await settle(tester);
      final newTrip = tester.widget<InkWell>(
        find.byKey(const Key('driver-action-new-trip')),
      );
      expect(newTrip.onTap, isNull);
      expect(find.byKey(const Key('driver-trips-off')), findsOneWidget);
    });

    testWidgets('offline, the rules kept on the phone still apply', (
      tester,
    ) async {
      final h = await signedIn(
        tester,
        roles: ['driver'],
        preferences: {'workflow_settings_v1:$_orgId': jsonEncode(off.toJson())},
      );
      h.api.offline = true;
      await tester.pumpWidget(h.screen(const TripsScreen()));
      await settle(tester);
      expect(find.byKey(const Key('driver-trips-off')), findsOneWidget);
    });

    testWidgets('with charges off, ending a trip has no Add charge', (
      tester,
    ) async {
      final h = await signedIn(tester, roles: ['driver']);
      h.api.workflow = off;
      final trip = Trip.fromJson(tripJson(status: 'started'));
      await tester.pumpWidget(h.screen(EndTripScreen(trip: trip)));
      await settle(tester);
      expect(find.byKey(const Key('end-add-charge')), findsNothing);
    });

    testWidgets('with the receipt rule off, the receipt photo is optional', (
      tester,
    ) async {
      final h = await signedIn(tester, roles: ['driver']);
      h.api
        ..workflow = off
        ..vehicleList = const [
          Vehicle(
            id: '0199c7a2-0000-7000-8000-0000000000aa',
            registrationNo: 'MH12AB1234',
            model: 'Innova Crysta',
            fuelType: 'diesel',
          ),
        ];
      await h.engine.cacheTrip(Trip.fromJson(tripJson(status: 'started')));
      await tester.pumpWidget(h.screen(const FuelFillScreen()));
      await settle(tester);
      expect(find.text('Receipt photo (optional)'), findsOneWidget);
    });
  });
}
