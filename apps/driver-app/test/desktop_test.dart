import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      'vehicles',
      'drivers',
      'analytics',
      'settlements',
      'settings',
    ]) {
      expect(find.byKey(Key('side-$section')), findsOneWidget);
    }
    // Alerts and review sit behind the header bell; documents live on each
    // vehicle and driver; managers are in settings.
    for (final gone in ['alerts', 'review', 'documents', 'members', 'fuel']) {
      expect(find.byKey(Key('side-$gone')), findsNothing);
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
    expect(find.byType(KpiCard), findsNWidgets(4));
    for (final card in ['cabs', 'drivers', 'unassigned', 'completed']) {
      expect(find.byKey(Key('kpi-$card')), findsOneWidget);
    }
    expect(find.byKey(const Key('dashboard-day')), findsOneWidget);
    expect(find.byKey(const Key('alerts-bell')), findsOneWidget);
    // New trips start from the hub's "Add trip", not a header button.
    expect(find.byKey(const Key('dashboard-new-trip')), findsNothing);
    // The hub sits beside the scheduled rides, under the cards.
    final hub = tester.getTopLeft(find.byKey(const Key('quick-ops')));
    final rides = tester.getTopLeft(find.byKey(const Key('scheduled-rides')));
    expect(hub.dx, greaterThan(rides.dx));
    expect(
      hub.dy,
      greaterThan(tester.getBottomLeft(find.byKey(const Key('kpi-cabs'))).dy),
    );
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

  testWidgets('the logo and name go back to the dashboard', (tester) async {
    await desktop(tester);
    await tester.tap(find.byKey(const Key('side-vehicles')));
    await settle(tester);
    expect(find.byKey(const Key('kpi-cabs')), findsNothing);

    await tester.tap(find.text('Fleet Sarthi'));
    await settle(tester);
    expect(find.byKey(const Key('kpi-cabs')), findsOneWidget);
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

  testWidgets('the browser tab is named after the section', (tester) async {
    final titles = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemChrome.setApplicationSwitcherDescription') {
          titles.add((call.arguments as Map)['label']! as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await desktop(tester);
    expect(titles.last, 'Dashboard - Fleet Sarthi');
    await tester.tap(find.byKey(const Key('side-trips')));
    await settle(tester);
    expect(titles.last, 'Trips - Fleet Sarthi');
    await tester.tap(find.byKey(const Key('side-vehicles')));
    await settle(tester);
    expect(titles.last, 'Vehicles - Fleet Sarthi');
  });

  testWidgets('every section lays out on the desktop', (tester) async {
    await desktop(tester);
    // Each section with what makes its desktop page: a table, a card grid, or
    // the wide form. A layout overflow anywhere fails the test.
    final pages = <String, Finder>{
      'vehicles': find.byType(CardGrid),
      'drivers': find.byType(CardGrid),
      'analytics': find.byKey(const Key('chart-revenue')),
      'settlements': find.byKey(const Key('settlement-table')),
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

  testWidgets('the header bell opens alerts and review, beside the sidebar', (
    tester,
  ) async {
    await desktop(tester);
    await tester.tap(find.byKey(const Key('alerts-bell')));
    await settle(tester);
    expect(find.byKey(const Key('alerts-inbox')), findsOneWidget);
    expect(find.byKey(const Key('owner-sidebar')), findsOneWidget);
    expect(find.byKey(const Key('alert-filters')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tab-review')));
    await settle(tester);
    expect(find.byKey(const Key('review-keep-typed')), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a laptop just below the desktop width keeps the rail', (
    tester,
  ) async {
    await desktop(tester, width: desktopMinWidth - 1);
    expect(find.byKey(const Key('owner-rail')), findsOneWidget);
    expect(find.byKey(const Key('owner-sidebar')), findsNothing);
  });
}
