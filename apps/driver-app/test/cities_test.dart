import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/l10n/app_localizations.dart';
import 'package:taxcy_driver/features/common/address_field.dart';
import 'package:taxcy_driver/features/common/cities.dart';

/// The pickup and drop fields now offer Indian cities from the bundled list,
/// with no geocoder behind them.
void main() {
  City city(
    String name,
    String state, [
    double lat = 18.5,
    double lng = 73.8,
  ]) => City(name: name, state: state, point: GeoPoint(lat, lng));

  // Most populous first, as the asset is ordered.
  final cities = Cities.of([
    city('Mumbai', 'Maharashtra', 19.0728, 72.8826),
    city('Pune', 'Maharashtra', 18.5196, 73.8553),
    city('Punalur', 'Kerala', 9.0074, 76.9231),
    city('Shirdi', 'Maharashtra', 19.7667, 74.4833),
    city('Hyderabad', 'Telangana', 17.385, 78.4867),
    city('Hyderabad', 'Sindh', 25.3792, 68.3683),
  ]);

  group('searching the list', () {
    test('a name that starts with what was typed comes before one that merely '
        'contains it', () {
      expect(
        cities.search('pun').map((c) => c.name),
        containsAllInOrder(['Pune', 'Punalur']),
      );
    });

    test('ties are broken by population, as the list is ordered', () {
      expect(cities.search('m').first.name, 'Mumbai');
    });

    test('matching is case and space insensitive', () {
      expect(cities.search('  SHIRDI ').single.name, 'Shirdi');
    });

    test('a state name finds its cities', () {
      expect(cities.search('kerala').single.name, 'Punalur');
    });

    test('nothing typed finds nothing', () {
      expect(cities.search(''), isEmpty);
      expect(cities.search('   '), isEmpty);
    });

    test('somewhere not on the list finds nothing', () {
      expect(cities.search('Narnia'), isEmpty);
    });

    test('the number offered is capped', () {
      expect(cities.search('a', limit: 2), hasLength(lessThanOrEqualTo(2)));
    });
  });

  group('the field', () {
    Future<void> pump(
      WidgetTester tester,
      TextEditingController controller,
      void Function(City) onChosen,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AddressField(
              fieldKey: const Key('pickup'),
              controller: controller,
              label: 'Pickup',
              icon: Icons.trip_origin,
              cities: cities,
              onChosen: onChosen,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('typing offers cities with their state underneath', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pump(tester, controller, (_) {});

      await tester.enterText(find.byKey(const Key('pickup')), 'pun');
      await tester.pumpAndSettle();
      expect(find.text('Pune'), findsOneWidget);
      expect(find.text('Punalur'), findsOneWidget);
      expect(find.text('Kerala'), findsOneWidget);
    });

    testWidgets('choosing a city fills the field and hands over its pin', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      City? chosen;
      await pump(tester, controller, (c) => chosen = c);

      await tester.enterText(find.byKey(const Key('pickup')), 'pun');
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('city-0')));
      await tester.pumpAndSettle();

      expect(controller.text, 'Pune, Maharashtra');
      expect(chosen?.point.lat, 18.5196);
      // The list closes and does not reopen for the text it just inserted.
      expect(find.byKey(const Key('city-0')), findsNothing);
    });

    testWidgets('two cities of the same name in different states both show', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pump(tester, controller, (_) {});

      await tester.enterText(find.byKey(const Key('pickup')), 'hyderabad');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Hyderabad'), findsNWidgets(2));
      expect(find.text('Telangana'), findsOneWidget);
      expect(find.text('Sindh'), findsOneWidget);
    });

    testWidgets('somewhere not on the list says so and stays typed', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await pump(tester, controller, (_) {});

      await tester.enterText(find.byKey(const Key('pickup')), 'Baner Road');
      await tester.pumpAndSettle();
      expect(
        find.text('No matching city; you can type the address instead'),
        findsOneWidget,
      );
      expect(controller.text, 'Baner Road');
    });
  });

  group('the bundled data', () {
    // Read straight off disk rather than through rootBundle, which a plain
    // flutter test does not serve. The asset is the same file.
    final rows =
        (jsonDecode(File('assets/data/in_cities.json').readAsStringSync())
                as List<dynamic>)
            .cast<List<dynamic>>();
    final loaded = Cities.of([
      for (final row in rows)
        City(
          name: row[0] as String,
          state: row[1] as String,
          point: GeoPoint(
            (row[2] as num).toDouble(),
            (row[3] as num).toDouble(),
          ),
        ),
    ]);

    test('covers the country, most populous first', () {
      expect(loaded.all.length, greaterThan(2000));
      expect(loaded.all.first.name, 'Mumbai');
      expect(loaded.all.map((c) => c.state).toSet().length, greaterThan(25));
    });

    test('has the places a fleet actually books between', () {
      for (final place in [
        'Mumbai',
        'Delhi',
        'Bengaluru',
        'Chennai',
        'Hyderabad',
        'Pune',
        'Nashik',
        'Shirdi',
        'Lonavla',
      ]) {
        expect(
          loaded.search(place).map((c) => c.name),
          contains(place),
          reason: place,
        );
      }
    });

    test('every row has a state and a pin inside India', () {
      final bad = loaded.all
          .where(
            (c) =>
                c.state.isEmpty ||
                c.point.lat < 6 ||
                c.point.lat > 38 ||
                c.point.lng < 68 ||
                c.point.lng > 98,
          )
          .map((c) => c.label)
          .toList();
      expect(bad, isEmpty);
    });
  });
}
