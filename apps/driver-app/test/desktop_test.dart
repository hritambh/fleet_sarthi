import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/app/app.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/owner/owner_widgets.dart';

import 'support/fakes.dart';
import 'support/harness.dart';
import 'support/owner_fakes.dart';

/// Owner mode on a laptop-sized browser window.
Future<Harness> desktop(WidgetTester tester, {double width = 1440}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = Size(width, 1000);
  addTearDown(tester.view.reset);
  final h = await Harness.create(
    session: Session.fromJson(sessionJson(roles: ['owner'])),
  );
  addTearDown(h.dispose);
  await tester.pumpWidget(h.wrap(const TaxcyDriverApp()));
  await settle(tester);
  return h;
}

void main() {
  testWidgets('every section is in the sidebar, not behind More', (
    tester,
  ) async {
    await desktop(tester);
    expect(find.byKey(const Key('owner-sidebar')), findsOneWidget);
    expect(find.byKey(const Key('owner-rail')), findsNothing);
    expect(find.byKey(const Key('owner-nav')), findsNothing);
    for (final section in [
      'dashboard',
      'trips',
      'alerts',
      'review',
      'vehicles',
      'drivers',
      'documents',
      'fuel',
      'settlements',
      'members',
      'settings',
    ]) {
      expect(find.byKey(Key('side-$section')), findsOneWidget);
    }
    // The fleet and who's signed in.
    expect(find.text('Sharma Travels'), findsWidgets);
    expect(find.text('Ramesh Kumar'), findsOneWidget);
  });

  testWidgets('the dashboard greets and leads with headline numbers', (
    tester,
  ) async {
    await desktop(tester);
    expect(find.textContaining('Ramesh'), findsWidgets);
    expect(find.byType(MetricCard), findsNWidgets(4));
    expect(find.byKey(const Key('dashboard-new-trip')), findsOneWidget);
  });

  testWidgets('pages open inside the content area, beside the sidebar', (
    tester,
  ) async {
    await desktop(tester);
    await tester.tap(find.byKey(const Key('side-vehicles')));
    await settle(tester);
    // Vehicles are cards with their number plate; adding one is a header button.
    expect(find.text('MH 12 AB 1234'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(
      find.ancestor(
        of: find.byKey(const Key('add-vehicle')),
        matching: find.byType(AppBar),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('vehicle-$vehicleId')));
    await settle(tester);
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.byKey(const Key('owner-sidebar')), findsOneWidget);

    // Clicking the section again goes back to its list.
    await tester.tap(find.byKey(const Key('side-vehicles')));
    await settle(tester);
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsNothing);
    expect(find.byKey(const ValueKey('vehicle-$vehicleId')), findsOneWidget);
  });

  testWidgets('trips are a table with the new-trip button in the header', (
    tester,
  ) async {
    await desktop(tester);
    await tester.tap(find.byKey(const Key('side-trips')));
    await settle(tester);
    expect(find.byKey(const Key('trip-table')), findsOneWidget);
    expect(find.text('ROUTE'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(
      tester.widget(find.byKey(const Key('owner-new-trip'))),
      isA<FilledButton>(),
    );
  });

  testWidgets('every section lays out on the desktop', (tester) async {
    await desktop(tester);
    // Each section with what makes its desktop page: a table, a card grid, or
    // the wide form. A layout overflow anywhere fails the test.
    final pages = <String, Finder>{
      'alerts': find.byType(Card),
      'review': find.byKey(const Key('review-keep-typed')),
      'vehicles': find.byType(CardGrid),
      'drivers': find.byType(CardGrid),
      'documents': find.byKey(const Key('document-table')),
      'fuel': find.byType(CardGrid),
      'settlements': find.byKey(const Key('settlement-table')),
      'members': find.byKey(const Key('member-table')),
      'settings': find.byKey(const Key('save-thresholds')),
    };
    for (final MapEntry(key: section, value: marker) in pages.entries) {
      await tester.tap(find.byKey(Key('side-$section')));
      await settle(tester);
      expect(marker, findsWidgets, reason: section);
      expect(tester.takeException(), isNull, reason: section);
    }
  });

  testWidgets('settings put the thresholds beside language and pay', (
    tester,
  ) async {
    await desktop(tester);
    await tester.tap(find.byKey(const Key('side-settings')));
    await settle(tester);
    final thresholds = tester.getTopLeft(find.byKey(const Key('audit-k')));
    final language = tester.getTopLeft(
      find.byKey(const Key('settings-language')),
    );
    // Side by side, not stacked; and two threshold fields share a row.
    expect(language.dx, greaterThan(thresholds.dx));
    expect(
      tester.getTopLeft(find.byKey(const Key('audit-min'))).dy,
      thresholds.dy,
    );
  });

  testWidgets('a laptop just below the desktop width keeps the rail', (
    tester,
  ) async {
    await desktop(tester, width: desktopMinWidth - 1);
    expect(find.byKey(const Key('owner-rail')), findsOneWidget);
    expect(find.byKey(const Key('owner-sidebar')), findsNothing);
  });
}
