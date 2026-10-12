import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/app/app.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/owner/alerts_screen.dart';
import 'package:taxcy_driver/features/owner/analytics_screen.dart';
import 'package:taxcy_driver/features/owner/dashboard_screen.dart';
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
      expect(find.byKey(const Key('alert-status-filter')), findsOneWidget);

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
      expect(find.text('50% ready'), findsOneWidget);
      expect(find.text('1 on trip · 0 inactive'), findsOneWidget);
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
