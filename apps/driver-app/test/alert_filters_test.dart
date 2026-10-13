import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/owner/alerts_screen.dart';

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

Future<void> pick(WidgetTester tester, String key) async {
  final chip = find.byKey(ValueKey('filter-$key'));
  await tester.ensureVisible(chip);
  await tester.tap(chip);
  await tester.pump();
}

void main() {
  testWidgets('several values per filter, shown as removable chips', (
    tester,
  ) async {
    final h = await owner(tester);
    await tester.pumpWidget(h.screen(const AlertsScreen()));
    await settle(tester);
    // Open alerts by default, shown as a chip.
    expect(h.owner.last('alerts').args['status'], 'open');
    expect(find.byKey(const ValueKey('filter-chip-status-open')), findsOne);

    await tester.tap(find.byKey(const Key('alert-filters')));
    await tester.pumpAndSettle();
    await pick(tester, 'status-acknowledged');
    await pick(tester, 'kind-fuel_cost_high');
    await pick(tester, 'kind-fuel_efficiency_low');
    await pick(tester, 'severity-critical');
    await pick(tester, 'vehicle-$vehicleId');
    await pick(tester, 'driver-$driverId');
    await tester.tap(find.byKey(const Key('alert-filters-apply')));
    await settle(tester);

    expect(h.owner.last('alerts').args, {
      'status': 'acknowledged,open',
      'kind': 'fuel_cost_high,fuel_efficiency_low',
      'severity': 'critical',
      'vehicleId': vehicleId,
      'driverId': driverId,
      'tripId': null,
    });
    expect(find.text('Filters (7)'), findsOneWidget);
    for (final chip in [
      'status-open',
      'status-acknowledged',
      'kind-fuel_cost_high',
      'severity-critical',
      'vehicle-$vehicleId',
      'driver-$driverId',
    ]) {
      expect(find.byKey(ValueKey('filter-chip-$chip')), findsOne, reason: chip);
    }
    // Vehicle and driver chips are named, not ids.
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('filter-chip-vehicle-$vehicleId')),
        matching: find.text('MH 12 AB 1234'),
      ),
      findsOne,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('filter-chip-driver-$driverId')),
        matching: find.text('Ramesh Kumar'),
      ),
      findsOne,
    );

    // Removing one chip narrows the filter; Clear all drops every filter.
    await tester.tap(
      find.descendant(
        of: find.byKey(const ValueKey('filter-chip-severity-critical')),
        matching: find.byIcon(Icons.clear),
      ),
    );
    await settle(tester);
    expect(h.owner.last('alerts').args['severity'], isNull);

    await tester.tap(find.byKey(const Key('alert-filters-clear')));
    await settle(tester);
    expect(h.owner.last('alerts').args, {
      'status': null,
      'kind': null,
      'severity': null,
      'vehicleId': null,
      'driverId': null,
      'tripId': null,
    });
    expect(find.text('Filters'), findsOneWidget);
  });

  testWidgets('cancelling the picker keeps the filters', (tester) async {
    final h = await owner(tester);
    await tester.pumpWidget(h.screen(const AlertsScreen()));
    await settle(tester);
    await tester.tap(find.byKey(const Key('alert-filters')));
    await tester.pumpAndSettle();
    await pick(tester, 'severity-info');
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(h.owner.last('alerts').args['severity'], isNull);
    expect(
      find.byKey(const ValueKey('filter-chip-severity-info')),
      findsNothing,
    );
  });
}
