import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/app/app.dart';
import 'package:taxcy_driver/app/preferences.dart';
import 'package:taxcy_driver/app/workspaces.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/core/db/database.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

// U1 owns fleet A (vehicle V1) and drives V2 for U2's fleet B.
const fleetA = '0199c7a2-0000-7000-8000-00000000000a';
const fleetB = '0199c7a2-0000-7000-8000-00000000000b';
const ownsA = Membership(
  orgId: fleetA,
  orgName: 'Kumar Cabs',
  roles: ['owner'],
);
const drivesB = Membership(
  orgId: fleetB,
  orgName: 'Sharma Travels',
  roles: ['driver'],
);

Session sessionWith(List<Membership> memberships, {String? activeOrgId}) =>
    Session.fromJson({
      ...sessionJson(),
      'activeOrgId': activeOrgId,
      'memberships': memberships.map((m) => m.toJson()).toList(),
    });

Future<Harness> start(WidgetTester tester, Session session) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(420, 2400);
  addTearDown(tester.view.reset);
  final h = await Harness.create(session: session);
  addTearDown(h.dispose);
  await tester.pumpWidget(h.wrap(const TaxcyDriverApp()));
  await settle(tester);
  return h;
}

Future<void> openSwitcherFromOwnerMode(WidgetTester tester) async {
  await tester.tap(find.text('More'));
  await settle(tester);
  await tester.tap(find.byKey(const Key('switch-workspace')));
  await tester.pumpAndSettle();
}

void main() {
  test('workspaces: fleets they run first, then fleets they drive for', () {
    final both = sessionWith([
      drivesB,
      const Membership(orgId: fleetA, orgName: 'A', roles: ['owner', 'driver']),
    ], activeOrgId: fleetA);
    expect(workspacesFor(both).map((w) => '${w.mode.name} ${w.orgId}'), [
      'owner $fleetA',
      'driver $fleetB',
      'driver $fleetA',
    ]);
  });

  testWidgets('an owner who drives for another fleet switches into it', (
    tester,
  ) async {
    final h = await start(
      tester,
      sessionWith([ownsA, drivesB], activeOrgId: fleetA),
    );
    h.auth.currentMemberships = [ownsA, drivesB];
    expect(find.byKey(const Key('owner-nav')), findsOneWidget);

    await openSwitcherFromOwnerMode(tester);
    expect(find.text('Manage Kumar Cabs'), findsOneWidget);
    expect(find.text('Drive for Sharma Travels'), findsOneWidget);
    await tester.tap(find.byKey(const Key('workspace-driver-$fleetB')));
    await settle(tester);

    expect(find.text('My trips'), findsOneWidget);
    expect(h.auth.calls.last.args, {'orgId': fleetB});
    expect((await h.sessions.load())!.activeOrgId, fleetB);
    expect(h.prefs.getString('app_mode_v1'), 'driver');

    // And back to managing their own fleet.
    await tester.tap(find.byKey(const Key('driver-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('switch-workspace')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('workspace-owner-$fleetA')));
    await settle(tester);
    expect(find.byKey(const Key('owner-nav')), findsOneWidget);
    expect((await h.sessions.load())!.activeOrgId, fleetA);
  });

  testWidgets('switching fleets waits until trip data has synced', (
    tester,
  ) async {
    final h = await start(
      tester,
      sessionWith([ownsA, drivesB], activeOrgId: fleetA),
    );
    await h.db
        .into(h.db.outboxItems)
        .insert(
          OutboxItemsCompanion.insert(
            key: 'k1',
            kind: 'trip.start',
            payload: '{}',
            tripId: const Value('t1'),
            createdAt: DateTime(2026, 10, 9),
          ),
        );

    await openSwitcherFromOwnerMode(tester);
    await tester.tap(find.byKey(const Key('workspace-driver-$fleetB')));
    await settle(tester);

    expect(find.textContaining("haven't been sent yet"), findsOneWidget);
    expect(h.auth.names, isNot(contains('switchOrg')));
    expect(find.byKey(const Key('owner-nav')), findsOneWidget);
    expect(await h.db.select(h.db.outboxItems).get(), hasLength(1));
  });

  testWidgets('someone in no fleet sets up their own and lands in owner mode', (
    tester,
  ) async {
    final h = await start(tester, sessionWith(const []));
    expect(find.text('Welcome to Fleet Sarthi'), findsOneWidget);
    expect(find.textContaining('+919000000011'), findsOneWidget);

    await tester.tap(find.byKey(const Key('set-up-fleet')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('fleet-name')), 'Kumar Cabs');
    await tester.tap(find.byKey(const Key('create-fleet')));
    await settle(tester);

    expect(h.auth.calls.last.args, {'name': 'Kumar Cabs', 'kind': 'fleet'});
    expect(find.byKey(const Key('owner-nav')), findsOneWidget);
    expect(h.prefs.getString('app_mode_v1'), AppMode.owner.name);
  });

  testWidgets('a new driver checks again once an owner has added them', (
    tester,
  ) async {
    final h = await start(tester, sessionWith(const []));

    await tester.tap(find.byKey(const Key('check-again')));
    await settle(tester);
    expect(find.text('No owner has added you yet.'), findsOneWidget);

    h.auth.currentMemberships = [drivesB];
    await tester.tap(find.byKey(const Key('check-again')));
    await settle(tester);
    expect(h.auth.calls.last.args, {'orgId': fleetB});
    expect(find.text('My trips'), findsOneWidget);
  });
}
