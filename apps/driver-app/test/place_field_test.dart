import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/core/places/places_api.dart';
import 'package:taxcy_driver/features/common/place_field.dart';
import 'package:taxcy_driver/features/owner/trips/create_trip_screen.dart';
import 'package:taxcy_driver/features/trips/new_trip_screen.dart';

import 'support/fakes.dart';
import 'support/harness.dart';
import 'support/owner_fakes.dart';

Future<Harness> setUp(
  WidgetTester tester, {
  List<String> roles = const ['owner'],
  String language = 'en',
  double width = 420,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = Size(width, 2000);
  addTearDown(tester.view.reset);
  final h = await Harness.create(
    session: Session.fromJson(sessionJson(roles: roles)),
    language: language,
  );
  h.places.results = const [pune, hinjawadi];
  addTearDown(h.dispose);
  return h;
}

/// Types into a field, waits out the typing pause and lets the answer show.
Future<void> type(WidgetTester tester, String key, String text) async {
  await tester.enterText(find.byKey(Key(key)), text);
  await tester.pump(PlaceField.debounce + const Duration(milliseconds: 50));
  await settle(tester);
  await tester.pump();
}

Finder option(String label) => find.byKey(ValueKey('place-option-$label'));

const pune = PlaceSuggestion(
  label: 'Pune',
  detail: 'Maharashtra',
  point: GeoPoint(18.52, 73.86),
);
const hinjawadi = PlaceSuggestion(
  label: 'Hinjawadi Phase 1, Pune',
  detail: 'Maharashtra',
  point: GeoPoint(18.5912, 73.7389),
);
const olaPune = PlaceSuggestion(
  label: 'Pune Railway Station',
  detail: 'Maharashtra',
  point: GeoPoint(18.528, 73.874),
  source: PlaceSource.ola,
);

String fieldText(WidgetTester tester, String key) =>
    tester.widget<TextFormField>(find.byKey(Key(key))).controller!.text;

void main() {
  group('owner: new trip', () {
    testWidgets(
      'three letters suggest places, credited; picking sets the pin',
      (tester) async {
        final h = await setUp(tester);
        await tester.pumpWidget(h.screen(const CreateTripScreen()));
        await settle(tester);
        expect(find.text('Add map pin'), findsNWidgets(2));

        await type(tester, 'owner-trip-to', 'hinj');
        expect(h.places.queries, ['hinj']);
        expect(option('Hinjawadi Phase 1, Pune'), findsOneWidget);
        expect(find.text('Maharashtra'), findsWidgets);
        expect(find.byKey(const Key('place-credit')), findsOneWidget);

        await tester.tap(option('Hinjawadi Phase 1, Pune'));
        await tester.pumpAndSettle();
        expect(fieldText(tester, 'owner-trip-to'), 'Hinjawadi Phase 1, Pune');
        // The drop now has a pin; the pickup still doesn't.
        expect(find.text('Change'), findsOneWidget);
        expect(find.text('Add map pin'), findsOneWidget);
        // Picking doesn't search again for the label it filled in.
        expect(h.places.queries, ['hinj']);
      },
    );

    testWidgets('each provider in the list is credited once', (tester) async {
      final h = await setUp(tester);
      Finder credit(String source) =>
          find.byKey(ValueKey('place-credit-$source'));
      await tester.pumpWidget(h.screen(const CreateTripScreen()));
      await settle(tester);

      // Geoapify only (the fixtures carry no source).
      await type(tester, 'owner-trip-from', 'hinj');
      expect(credit('geoapify'), findsOneWidget);
      expect(credit('ola'), findsNothing);

      // Ola only.
      h.places.results = const [olaPune];
      await type(tester, 'owner-trip-from', 'pune');
      expect(find.text('Powered by Ola Maps'), findsOneWidget);
      expect(credit('geoapify'), findsNothing);

      // Both.
      h.places.results = const [olaPune, hinjawadi, pune];
      await type(tester, 'owner-trip-from', 'pune s');
      expect(credit('ola'), findsOneWidget);
      expect(credit('geoapify'), findsOneWidget);
    });

    testWidgets('two letters ask nothing', (tester) async {
      final h = await setUp(tester);
      await tester.pumpWidget(h.screen(const CreateTripScreen()));
      await settle(tester);
      await type(tester, 'owner-trip-from', 'pu');
      expect(find.byKey(const Key('place-options')), findsNothing);
      expect(h.places.queries, isEmpty);
    });

    testWidgets('only the text typing paused on is asked', (tester) async {
      final h = await setUp(tester);
      await tester.pumpWidget(h.screen(const CreateTripScreen()));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('owner-trip-from')), 'pun');
      await tester.pump(const Duration(milliseconds: 100));
      await type(tester, 'owner-trip-from', 'pune st');
      expect(h.places.queries, ['pune st']);
    });

    testWidgets('typed text is kept without picking a suggestion', (
      tester,
    ) async {
      final h = await setUp(tester);
      await tester.pumpWidget(h.screen(const CreateTripScreen()));
      await settle(tester);
      await type(tester, 'owner-trip-from', 'Pune Station, platform 1');
      expect(find.text('Pune Station, platform 1'), findsOneWidget);
      expect(find.text('Add map pin'), findsNWidgets(2));
    });

    testWidgets('nothing found (or search off, or offline): no list', (
      tester,
    ) async {
      final h = await setUp(tester);
      h.places.results = const [];
      await tester.pumpWidget(h.screen(const CreateTripScreen()));
      await settle(tester);
      await type(tester, 'owner-trip-from', 'xyzzy');
      expect(h.places.queries, ['xyzzy']);
      expect(find.byKey(const Key('place-options')), findsNothing);
    });
  });

  testWidgets('a spinner shows while the search answers', (tester) async {
    final h = await setUp(tester);
    h.places.gate = Completer<void>();
    await tester.pumpWidget(h.screen(const CreateTripScreen()));
    await settle(tester);
    await type(tester, 'owner-trip-from', 'hinj');
    expect(find.byKey(const Key('place-searching')), findsOneWidget);
    expect(option('Pune'), findsNothing);

    h.places.gate!.complete();
    await settle(tester);
    await tester.pump();
    expect(find.byKey(const Key('place-searching')), findsNothing);
    expect(option('Pune'), findsOneWidget);
  });

  testWidgets('driver: the same suggestions fill the pickup', (tester) async {
    final h = await setUp(tester, roles: ['driver']);
    h.api.vehicleList = [Vehicle.fromJson(vehicleJson())];
    await tester.pumpWidget(h.screen(const NewTripScreen()));
    await settle(tester);
    await type(tester, 'trip-from', 'pun');
    await tester.tap(option('Pune'));
    await tester.pumpAndSettle();
    expect(fieldText(tester, 'trip-from'), 'Pune');
  });

  // On a small phone in both languages, with the list and the credit showing:
  // any overflow fails the test.
  for (final language in ['en', 'hi', 'kn', 'mr']) {
    testWidgets('360 px: suggestions fit ($language)', (tester) async {
      final h = await setUp(tester, language: language, width: 360);
      h.places.results = const [olaPune, pune, hinjawadi]; // both credits
      await tester.pumpWidget(h.screen(const CreateTripScreen()));
      await settle(tester);
      await type(tester, 'owner-trip-from', 'hinjawadi ph');
      expect(find.byKey(const Key('place-credit')), findsOneWidget);
    });
  }
}
