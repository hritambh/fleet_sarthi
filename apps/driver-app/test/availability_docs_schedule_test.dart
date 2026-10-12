import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/json.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/owner/documents_screen.dart';
import 'package:taxcy_driver/features/owner/trips/create_trip_screen.dart';
import 'package:taxcy_driver/features/owner/trips/owner_trip_detail_screen.dart';
import 'package:taxcy_driver/features/owner/vehicle_schedule.dart';

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

JsonMap busy(String id) => {
  'id': id,
  'tripId': '0199c7a2-0000-7000-8000-0000000007aa',
  'from': '2026-10-10T08:30:00.000Z',
  'to': '2026-10-10T12:30:00.000Z',
};

/// Opens the dropdown whose label is [label].
Future<void> openDropdown(WidgetTester tester, String label) async {
  final field = find.ancestor(
    of: find.text(label).last,
    matching: find.byType(DropdownButtonFormField<String?>),
  );
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
}

DropdownMenuItem<String?> menuItem(WidgetTester tester, String id) => tester
    .widget<DropdownMenuItem<String?>>(find.byKey(ValueKey('pick-$id')).last);

void main() {
  group('availability', () {
    testWidgets('a busy driver is listed but greyed out and labelled', (
      tester,
    ) async {
      final h = await owner(tester);
      h.owner.availabilityJson = {
        'vehicles': [],
        'drivers': [busy(driverId)],
      };
      await tester.pumpWidget(h.screen(const CreateTripScreen()));
      await settle(tester);
      expect(h.owner.last('availability').args['from'], isNotNull);

      await openDropdown(tester, 'Driver (optional)');
      expect(menuItem(tester, driverId).enabled, isFalse);
      expect(menuItem(tester, driver2Id).enabled, isTrue);
      expect(find.textContaining('Busy'), findsWidgets);
    });

    testWidgets('assigning ignores the trip itself and blocks a busy pick', (
      tester,
    ) async {
      final h = await owner(tester);
      const tripId = '0199c7a2-0000-7000-8000-000000000001';
      h.owner.availabilityJson = {
        'vehicles': [busy(vehicle2Id)],
        'drivers': [],
      };
      await tester.pumpWidget(
        h.screen(const OwnerTripDetailScreen(tripId: tripId)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('trip-assign')));
      await settle(tester);
      expect(h.owner.last('availability').args['excludeTripId'], tripId);

      await openDropdown(tester, 'Vehicle');
      expect(menuItem(tester, vehicle2Id).enabled, isFalse);
      expect(menuItem(tester, vehicleId).enabled, isTrue);
    });
  });

  group('document files', () {
    testWidgets('upload a PDF instead of a photo', (tester) async {
      final h = await owner(tester);
      // The picked file's bytes, as the real picker would have stored them.
      h.photoStore.photos['/photos/picked-document'] = Uint8List(2048);
      await tester.pumpWidget(
        h.screen(const DocumentFormScreen(vehicleId: vehicleId)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('document-upload-file')));
      await settle(tester);
      expect(find.text('insurance.pdf'), findsOneWidget);
      expect(find.text('PDF document'), findsOneWidget);

      await tester.tap(find.byKey(const Key('document-expires')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('document-save')));
      await settle(tester);
      expect(h.api.names, contains('registerMedia'));
      expect(h.owner.last('createDocument').args['mediaId'], 'picked-document');
    });

    testWidgets('a file over 15 MB is refused', (tester) async {
      final h = await owner(tester);
      h.pickFile = null;
      await tester.pumpWidget(
        h.screen(const DocumentFormScreen(vehicleId: vehicleId)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('document-upload-file')));
      await settle(tester);
      expect(find.text('That file is larger than 15 MB.'), findsOneWidget);
    });

    testWidgets('a PDF document opens outside the app', (tester) async {
      final h = await owner(tester);
      const mediaId = '0199c7a2-0000-7000-8000-0000000009aa';
      h.owner
        ..serveMediaUrls = true
        ..documentList = [
          {
            ...documentJson(),
            'mediaId': mediaId,
            'mediaContentType': 'application/pdf',
          },
        ];
      await tester.pumpWidget(
        h.screen(
          const Scaffold(
            body: DocumentsList(
              query: (
                vehicleId: vehicleId,
                driverId: null,
                expiringWithinDays: null,
              ),
            ),
          ),
        ),
      );
      await settle(tester);
      await tester.tap(
        find.byKey(
          const ValueKey(
            'document-menu-${'0199c7a2-0000-7000-8000-000000000d01'}',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('View document'), findsOneWidget);
      await tester.tap(find.text('View document'));
      await settle(tester);
      expect(h.openedUrls.single.toString(), 'https://files.test/$mediaId');
    });
  });

  group('vehicle schedule', () {
    testWidgets('marks booked days and lists the chosen day\'s trips', (
      tester,
    ) async {
      final h = await owner(tester);
      const tripId = '0199c7a2-0000-7000-8000-0000000008aa';
      h.owner.tripsById
        ..clear()
        ..[tripId] = tripJson(
          id: tripId,
          status: 'assigned',
          // 12 Oct 2026, 2:00 pm IST.
          scheduledStartAt: DateTime.utc(2026, 10, 12, 8, 30),
        );
      await tester.pumpWidget(
        h.screen(
          Scaffold(
            body: VehicleSchedule(vehicleId: vehicleId, now: now),
          ),
        ),
      );
      await settle(tester);
      final query = h.owner.last('trips').args;
      expect(query['vehicleId'], vehicleId);
      expect(query['overlapping'], 'true');
      expect(query['from'], '2026-09-30T18:30:00.000Z');
      expect(query['to'], '2026-10-31T18:30:00.000Z');
      expect(find.text('October 2026'), findsOneWidget);

      // Today (the 10th) has no trips; the 12th does.
      expect(find.text('No trips this day.'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('schedule-day-2026-10-12')));
      await tester.pump();
      expect(find.text('No trips this day.'), findsNothing);
      expect(find.textContaining('Pune Station'), findsWidgets);

      await tester.tap(find.byKey(const Key('schedule-next')));
      await settle(tester);
      expect(find.text('November 2026'), findsOneWidget);
      expect(h.owner.last('trips').args['from'], '2026-10-31T18:30:00.000Z');
    });
  });
}
