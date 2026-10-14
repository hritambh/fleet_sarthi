import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/app/app.dart';
import 'package:taxcy_driver/core/api/json.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/owner/alerts_screen.dart';
import 'package:taxcy_driver/features/owner/analytics_screen.dart';
import 'package:taxcy_driver/features/owner/dashboard_screen.dart';
import 'package:taxcy_driver/features/owner/trips/create_trip_screen.dart';
import 'package:taxcy_driver/features/owner/trips/owner_trip_detail_screen.dart';
import 'package:taxcy_driver/features/owner/trips/trip_share.dart';
import 'package:taxcy_driver/features/owner/vehicles_screen.dart';

import 'support/fakes.dart';
import 'support/harness.dart';
import 'support/owner_fakes.dart';

/// A tall phone, so long owner pages fit without scrolling.
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

/// 10 Oct 2026, 11:30 IST.
final now = DateTime.utc(2026, 10, 10, 6);

Finder rich(String text) => find.text(text, findRichText: true);

void main() {
  group('navigation', () {
    testWidgets('phones get Dashboard, Trips and More, with a header bell', (
      tester,
    ) async {
      final h = await owner(tester);
      await tester.pumpWidget(h.wrap(const TaxcyDriverApp()));
      await settle(tester);
      expect(
        find.descendant(
          of: find.byKey(const Key('owner-nav')),
          matching: find.byType(NavigationDestination),
        ),
        findsNWidgets(3),
      );
      expect(find.byKey(const Key('alerts-bell')).hitTestable(), findsOne);

      await tester.tap(find.text('More'));
      await settle(tester);
      expect(find.byKey(const Key('more-analytics')), findsOneWidget);
      for (final gone in ['members', 'documents', 'review', 'fuel']) {
        expect(find.byKey(Key('more-$gone')), findsNothing, reason: gone);
      }
    });

    testWidgets('the bell opens alerts and review as two tabs', (tester) async {
      final h = await owner(tester);
      await tester.pumpWidget(h.wrap(const TaxcyDriverApp()));
      await settle(tester);
      // One open alert and one item to review.
      expect(
        find.descendant(
          of: find.byKey(const Key('alerts-bell')).hitTestable(),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('alerts-bell')).hitTestable());
      await settle(tester);
      expect(find.byKey(const Key('alerts-inbox')), findsOneWidget);
      expect(find.byKey(const Key('alert-filters')), findsOneWidget);

      await tester.tap(find.byKey(const Key('tab-review')));
      await settle(tester);
      expect(find.byKey(const Key('review-keep-typed')), findsOneWidget);
    });
  });

  group('dashboard', () {
    testWidgets('headline cards for the day, switchable to yesterday', (
      tester,
    ) async {
      final h = await owner(tester);
      await tester.pumpWidget(
        h.screen(DashboardScreen(onOpenTrips: () {}, now: now)),
      );
      await settle(tester);
      expect(h.owner.last('dashboard').args['date'], '2026-10-10');
      expect(rich('1 / 2'), findsNWidgets(2));
      // The cabs card shows each cab's day instead of a bar and footer.
      expect(find.byKey(const Key('cab-timelines')), findsOneWidget);
      expect(find.text('50% ready'), findsNothing);
      expect(find.text('1 on trip · 0 assigned'), findsOneWidget);
      expect(rich('1 pending'), findsOneWidget);
      expect(find.text('Needs cab'), findsOneWidget);
      expect(rich('3 runs'), findsOneWidget);
      expect(find.text('+50%'), findsOneWidget);
      expect(find.text('₹6,750 gross fare'), findsOneWidget);

      await tester.tap(find.text('Yesterday'));
      await settle(tester);
      expect(h.owner.last('dashboard').args['date'], '2026-10-09');
      expect(h.owner.last('trips').args['from'], '2026-10-08T18:30:00.000Z');
    });

    testWidgets('the cabs card shows each cab\'s day, free and booked', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final h = await owner(tester);
      // MH12AB1234 booked 09:00–11:00 IST; MH12CD5678 free all day.
      h.owner.tripsById
        ..clear()
        ..['t1'] = {
          ...tripJson(
            id: 't1',
            scheduledStartAt: DateTime.utc(2026, 10, 10, 3, 30),
          ),
          'scheduledEndAt': '2026-10-10T05:30:00.000Z',
        };
      await tester.pumpWidget(
        h.screen(DashboardScreen(onOpenTrips: () {}, now: now)),
      );
      await settle(tester);
      final card = find.byKey(const Key('kpi-cabs'));
      expect(
        find.descendant(of: card, matching: find.text('MH12AB1234')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('MH12CD5678')),
        findsOneWidget,
      );
      // 2 of 48 cab-hours booked.
      expect(find.text('96%'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('96% free')), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('MH12AB1234: 22 h free')),
        findsOneWidget,
      );
      expect(
        h.owner.calls.where(
          (c) => c.name == 'trips' && c.args['overlapping'] == 'true',
        ),
        isNotEmpty,
      );
      semantics.dispose();
    });

    testWidgets('with many cabs the card keeps its size: "+N more"', (
      tester,
    ) async {
      Future<Size> cabsCard(List<JsonMap> vehicles) async {
        final h = await owner(tester);
        h.owner.vehicleList = vehicles;
        await tester.pumpWidget(
          h.screen(DashboardScreen(onOpenTrips: () {}, now: now)),
        );
        await settle(tester);
        final size = tester.getSize(find.byKey(const Key('kpi-cabs')));
        await tester.pumpWidget(const SizedBox());
        return size;
      }

      // No cabs: the plain card with its bar and footer.
      final plain = await cabsCard([]);
      final busy = await cabsCard([
        for (var i = 0; i < 7; i++)
          vehicleJson(
            id: '0199c7a2-0000-7000-8000-0000000001${i}0',
            reg: 'MH12ZZ000$i',
          ),
      ]);
      expect(busy, plain);
    });

    testWidgets('more cabs than fit: three lines and "+N more"', (
      tester,
    ) async {
      final h = await owner(tester);
      h.owner.vehicleList = [
        for (var i = 0; i < 7; i++)
          vehicleJson(
            id: '0199c7a2-0000-7000-8000-0000000001${i}0',
            reg: 'MH12ZZ000$i',
          ),
      ];
      await tester.pumpWidget(
        h.screen(DashboardScreen(onOpenTrips: () {}, now: now)),
      );
      await settle(tester);
      expect(find.text('+4 more'), findsOneWidget);
      expect(find.text('MH12ZZ0002'), findsOneWidget);
      expect(find.text('MH12ZZ0003'), findsNothing);
    });

    testWidgets('"resolve queue" lists the unassigned trips', (tester) async {
      final h = await owner(tester);
      await tester.pumpWidget(
        h.screen(DashboardScreen(onOpenTrips: () {}, now: now)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('kpi-unassigned')));
      await settle(tester);
      expect(h.owner.last('trips').args['status'], 'created');
    });

    testWidgets('only the headline cards, hub, rides and open alerts', (
      tester,
    ) async {
      final h = await owner(tester);
      await tester.pumpWidget(
        h.screen(DashboardScreen(onOpenTrips: () {}, now: now)),
      );
      await settle(tester);
      expect(find.byKey(const Key('quick-ops')), findsOneWidget);
      expect(find.text('Quick Operations Hub'), findsOneWidget);
      for (final b in ['add-trip', 'tag-driver', 'add-driver', 'add-cab']) {
        expect(find.byKey(Key('quick-$b')), findsOneWidget, reason: b);
      }
      expect(find.byKey(const Key('scheduled-rides')), findsOneWidget);
      for (final gone in [
        'Today’s trips',
        'Needs your attention',
        'Documents due soon',
      ]) {
        expect(find.text(gone), findsNothing, reason: gone);
      }
      // The hub sits right below the four headline cards.
      expect(
        tester.getTopLeft(find.byKey(const Key('quick-ops'))).dy,
        greaterThan(
          tester.getBottomLeft(find.byKey(const Key('kpi-completed'))).dy,
        ),
      );
      expect(
        tester.getTopLeft(find.byKey(const Key('quick-ops'))).dy,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('scheduled-rides'))).dy,
        ),
      );
    });

    for (final (button, opens) in [
      ('add-cab', find.byType(VehicleFormScreen)),
      ('add-trip', find.byType(CreateTripScreen)),
      ('add-driver', find.byKey(const Key('invite-phone'))),
    ]) {
      testWidgets('hub $button opens its form', (tester) async {
        final h = await owner(tester);
        await tester.pumpWidget(
          h.screen(DashboardScreen(onOpenTrips: () {}, now: now)),
        );
        await settle(tester);
        await tester.tap(find.byKey(Key('quick-$button')));
        await settle(tester);
        expect(opens, findsOneWidget);
      });
    }

    testWidgets('rides of the day: cab and driver, or an Assign button', (
      tester,
    ) async {
      final h = await owner(tester);
      const assigned = '0199c7a2-0000-7000-8000-0000000006a1';
      const cancelled = '0199c7a2-0000-7000-8000-0000000006a2';
      const waiting = '0199c7a2-0000-7000-8000-000000000001';
      h.owner.tripsById
        ..[assigned] = tripJson(id: assigned)
        ..[cancelled] = tripJson(id: cancelled, status: 'cancelled');
      await tester.pumpWidget(
        h.screen(DashboardScreen(onOpenTrips: () {}, now: now)),
      );
      await settle(tester);
      for (final id in [assigned, cancelled, waiting]) {
        expect(find.byKey(ValueKey('ride-$id')), findsOneWidget, reason: id);
      }
      expect(find.text('Innova Crysta · MH 12 AB 1234'), findsNWidgets(2));
      final driver = tester.widget<Text>(
        find.byKey(const ValueKey('ride-driver-$assigned')),
      );
      expect(driver.data, startsWith('Ramesh Kumar · '));
      expect(driver.data, contains('00011'));
      expect(find.byKey(const ValueKey('ride-assign-$assigned')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('ride-assign-$waiting')));
      await settle(tester);
      expect(find.byType(AssignDialog), findsOneWidget);
    });

    testWidgets('Tag Driver picks a waiting trip, then assigns it', (
      tester,
    ) async {
      final h = await owner(tester);
      const waiting = '0199c7a2-0000-7000-8000-000000000001';
      await tester.pumpWidget(
        h.screen(DashboardScreen(onOpenTrips: () {}, now: now)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('quick-tag-driver')));
      await settle(tester);
      expect(h.owner.last('trips').args['status'], 'created');
      await tester.tap(find.byKey(const ValueKey('tag-trip-$waiting')));
      await settle(tester);
      expect(find.byType(AssignDialog), findsOneWidget);
    });
  });

  group('documents', () {
    testWidgets('a vehicle with a document due is flagged in the list', (
      tester,
    ) async {
      final h = await owner(tester);
      await tester.pumpWidget(h.screen(const VehiclesScreen()));
      await settle(tester);
      expect(find.byKey(const Key('docs-due-$vehicleId')), findsOneWidget);
      expect(find.byKey(const Key('docs-due-$vehicle2Id')), findsNothing);
    });

    testWidgets('a document alert opens the vehicle it belongs to', (
      tester,
    ) async {
      final h = await owner(tester);
      h.owner.alertList = [alertJson(kind: 'document_expiring')];
      await tester.pumpWidget(h.screen(const AlertsScreen()));
      await settle(tester);
      await tester.tap(find.text('Open documents'));
      await settle(tester);
      expect(find.byType(VehicleDetailScreen), findsOneWidget);
    });
  });

  group('trip share', () {
    const tripId = '0199c7a2-0000-7000-8000-0000000005aa';

    testWidgets('WhatsApp opens addressed to the customer, with the details', (
      tester,
    ) async {
      final h = await owner(tester);
      h.owner.tripsById[tripId] = tripJson(id: tripId);
      await tester.pumpWidget(
        h.screen(const OwnerTripDetailScreen(tripId: tripId)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('trip-whatsapp')));
      await settle(tester);

      final uri = h.openedUrls.single;
      expect(uri.host, 'wa.me');
      expect(uri.path, '/919822222222');
      final text = uri.queryParameters['text']!;
      for (final line in [
        'Trip details',
        'Customer: Anita Desai',
        'Pickup: Pune Station',
        'Drop: Mumbai Airport T2',
        'Cab: Innova Crysta · MH 12 AB 1234',
        'Driver: Ramesh Kumar (+91 90000 00011)',
        'Fare: ₹3,500',
      ]) {
        expect(text, contains(line));
      }
    });

    testWidgets('Copy puts the same details on the clipboard', (tester) async {
      final h = await owner(tester);
      h.owner.tripsById[tripId] = tripJson(id: tripId);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
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
      await tester.pumpWidget(
        h.screen(const OwnerTripDetailScreen(tripId: tripId)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('trip-copy')));
      await settle(tester);
      expect(copied, contains('Pickup: Pune Station'));
      expect(find.text('Trip details copied'), findsOneWidget);
    });

    test('without a customer number WhatsApp asks whom to send to', () {
      final uri = whatsAppUri('Hello there', null);
      expect(uri.toString(), 'https://wa.me/?text=Hello+there');
    });
  });

  group('analytics', () {
    testWidgets('month totals and per-trip averages for the chosen month', (
      tester,
    ) async {
      final h = await owner(tester);
      await tester.pumpWidget(h.screen(AnalyticsScreen(now: now)));
      await settle(tester);
      expect(h.owner.last('dailyAnalytics').args['month'], '2026-10');
      expect(find.text('173 km'), findsOneWidget);
      expect(find.text('₹2,250'), findsOneWidget);
      // All vehicles: fuel in rupees, since litres and kg don't add up.
      expect(find.text('Month total: ₹3,400'), findsOneWidget);
      expect(find.text('Month total: ₹6,750'), findsOneWidget);

      // One CNG car: its fuel in kg.
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('chart-fuel')),
          matching: find.byType(DropdownButtonFormField<String?>),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('MH 12 CD 5678').last);
      await tester.pumpAndSettle();
      expect(find.text('Month total: 8.0 kg'), findsOneWidget);

      await tester.tap(find.byKey(const Key('analytics-month')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('September').last);
      await settle(tester);
      expect(h.owner.last('dailyAnalytics').args['month'], '2026-09');
    });
  });
}
