import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/owner/trips/owner_trips_screen.dart';

import 'support/fakes.dart';
import 'support/harness.dart';
import 'support/owner_fakes.dart';

Future<Harness> owner(WidgetTester tester) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(420, 2400);
  addTearDown(tester.view.reset);
  final h = await Harness.create(
    session: Session.fromJson(sessionJson(roles: ['owner'])),
  );
  addTearDown(h.dispose);
  return h;
}

/// Opens a filter's menu and ticks each option, leaving the menu open.
Future<void> tick(WidgetTester tester, String id, List<String> values) async {
  await tester.tap(find.byKey(Key(id)));
  await tester.pumpAndSettle();
  for (final v in values) {
    // CheckboxMenuButton hands its key to the button inside it too.
    await tester.tap(find.byKey(Key('$id-$v')).first);
    await tester.pumpAndSettle();
  }
  // Close the menu: a tap on the sheet's empty top-right corner, which the
  // menu (as wide as the field, inside the sheet's padding) doesn't cover.
  final sheet = tester.getRect(find.byKey(const Key('trip-filters-sheet')));
  await tester.tapAt(Offset(sheet.right - 4, sheet.top + 4));
  await settle(tester);
}

/// Opens the filters sheet from the app bar.
Future<void> openFilters(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('trip-filters')));
  await settle(tester);
}

void main() {
  testWidgets('status, driver and vehicle filters each take several values', (
    tester,
  ) async {
    final h = await owner(tester);
    await tester.pumpWidget(h.screen(const OwnerTripsScreen()));
    await settle(tester);
    expect(h.owner.last('trips').args['status'], isNull);
    await openFilters(tester);
    expect(find.text('All statuses'), findsOne);

    await tick(tester, 'trip-status-filter', ['started', 'assigned']);
    expect(h.owner.last('trips').args['status'], 'assigned,started');
    expect(find.text('Assigned, On the road'), findsOne);

    await tick(tester, 'trip-driver-filter', [driverId]);
    await tick(tester, 'trip-vehicle-filter', [vehicleId]);
    final args = h.owner.last('trips').args;
    expect(args['status'], 'assigned,started');
    expect(args['driverId'], driverId);
    expect(args['vehicleId'], vehicleId);
    expect(find.text('MH 12 AB 1234'), findsOne);

    // Unticking one status keeps the other.
    await tick(tester, 'trip-status-filter', ['started']);
    expect(h.owner.last('trips').args['status'], 'assigned');

    await tester.tap(find.byKey(const Key('trip-filters-clear')));
    await settle(tester);
    final cleared = h.owner.last('trips').args;
    expect(cleared['status'], isNull);
    expect(cleared['driverId'], isNull);
    expect(cleared['vehicleId'], isNull);
    expect(find.byKey(const Key('trip-filters-clear')), findsNothing);
  });

  testWidgets('the dates filter opens as a pop-up over the trips page', (
    tester,
  ) async {
    final h = await owner(tester);
    await tester.pumpWidget(h.screen(const OwnerTripsScreen()));
    await settle(tester);
    await openFilters(tester);
    Future<void> open() async {
      await tester.tap(find.byKey(const Key('trip-date-filter')));
      await tester.pumpAndSettle();
    }

    // A dialog card over the trips page, not a page of its own.
    await open();
    // The card itself: the dialog's Material, inside its outer inset area.
    final popup = tester.getSize(
      find
          .descendant(
            of: find.byKey(const Key('date-range-popup')),
            matching: find.byType(Material),
          )
          .first,
    );
    expect(popup.width, lessThan(420));
    expect(popup.height, lessThan(2400));
    expect(find.byType(OwnerTripsScreen), findsOne);

    // Cancel leaves the filter as it was.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('date-range-popup')), findsNothing);
    expect(find.text('Any date'), findsOne);

    // A quick range applies at once.
    await open();
    await tester.tap(find.byKey(const Key('range-today')));
    await settle(tester);
    expect(find.byKey(const Key('date-range-popup')), findsNothing);
    expect(h.owner.last('trips').args['from'], isNotNull);
    expect(find.text('Any date'), findsNothing);

    // This week and this month cover the whole period, Monday to Sunday and
    // 1st to last day, so trips booked ahead show up.
    for (final (id, days) in [('week', 7), ('month', null)]) {
      await open();
      await tester.tap(find.byKey(Key('range-$id')));
      await settle(tester);
      final args = h.owner.last('trips').args;
      final from = DateTime.parse(args['from']! as String);
      final to = DateTime.parse(args['to']! as String);
      final span = to.difference(from).inDays;
      if (days != null) {
        expect(span, days);
        expect(
          from.toUtc().add(const Duration(hours: 5, minutes: 30)).weekday,
          DateTime.monday,
        );
      } else {
        expect(span, inInclusiveRange(28, 31));
      }
    }

    // Or a From day (the To day follows it), then Apply.
    await tester.tap(find.byTooltip('Any date'));
    await settle(tester);
    expect(find.text('Any date'), findsOne);
    await open();
    expect(
      tester
          .widget<FilledButton>(find.byKey(const Key('range-apply')))
          .onPressed,
      isNull,
    );
    await tester.tap(find.byKey(const Key('range-from')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('range-apply')));
    await settle(tester);
    expect(find.byKey(const Key('date-range-popup')), findsNothing);
    expect(find.text('Any date'), findsNothing);
  });

  // On a small phone in both languages: any overflow fails the test.
  for (final language in ['en', 'hi', 'kn', 'mr']) {
    testWidgets('360 px: the dates pop-up fits ($language)', (tester) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(360, 800);
      addTearDown(tester.view.reset);
      final h = await Harness.create(
        session: Session.fromJson(sessionJson(roles: ['owner'])),
        language: language,
      );
      addTearDown(h.dispose);
      await tester.pumpWidget(h.screen(const OwnerTripsScreen()));
      await settle(tester);
      await openFilters(tester);
      await tester.tap(find.byKey(const Key('trip-date-filter')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('date-range-popup')), findsOne);
    });
  }

  testWidgets('the dashboard link starts filtered to one status', (
    tester,
  ) async {
    final h = await owner(tester);
    await tester.pumpWidget(
      h.screen(const OwnerTripsScreen(initialStatus: 'created')),
    );
    await settle(tester);
    expect(h.owner.last('trips').args['status'], 'created');
    await openFilters(tester);
    await tester.tap(find.byKey(const Key('trip-status-filter-clear')));
    await settle(tester);
    expect(h.owner.last('trips').args['status'], isNull);
  });

  testWidgets('on a phone the filters are in a sheet, not on the page', (
    tester,
  ) async {
    final h = await owner(tester);
    await tester.pumpWidget(h.screen(const OwnerTripsScreen()));
    await settle(tester);
    const fields = [
      'trip-status-filter',
      'trip-date-filter',
      'trip-driver-filter',
      'trip-vehicle-filter',
    ];
    for (final key in fields) {
      expect(find.byKey(Key(key)), findsNothing);
    }
    Badge badge() => tester.widget<Badge>(
      find.descendant(
        of: find.byKey(const Key('trip-filters')),
        matching: find.byType(Badge),
      ),
    );
    expect(badge().isLabelVisible, isFalse);

    // The app bar's filter button opens all four in a column.
    await openFilters(tester);
    final sheet = find.byKey(const Key('trip-filters-sheet'));
    expect(sheet, findsOne);
    var above = 0.0;
    for (final key in fields) {
      final field = find.descendant(of: sheet, matching: find.byKey(Key(key)));
      expect(field, findsOne);
      final top = tester.getTopLeft(field).dy;
      expect(top, greaterThan(above), reason: '$key is below the one before');
      above = top;
    }

    // A change applies at once; Apply closes the sheet and the dot shows the
    // list is filtered.
    await tick(tester, 'trip-status-filter', ['assigned']);
    expect(h.owner.last('trips').args['status'], 'assigned');
    await tester.tap(find.byKey(const Key('trip-filters-apply')));
    await tester.pumpAndSettle();
    expect(sheet, findsNothing);
    expect(badge().isLabelVisible, isTrue);
  });

  testWidgets('on the desktop the filters stay in a row above the table', (
    tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(1400, 900);
    addTearDown(tester.view.reset);
    final h = await Harness.create(
      session: Session.fromJson(sessionJson(roles: ['owner'])),
    );
    addTearDown(h.dispose);
    await tester.pumpWidget(h.screen(const OwnerTripsScreen()));
    await settle(tester);
    expect(find.byKey(const Key('trip-filters')), findsNothing);
    expect(find.byKey(const Key('trip-status-filter')), findsOne);
    expect(find.byKey(const Key('trip-vehicle-filter')), findsOne);
  });
}
