import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/json.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/core/api/owner_models.dart';
import 'package:taxcy_driver/core/media/captured_photo.dart';
import 'package:taxcy_driver/core/media/file_pick.dart';
import 'package:taxcy_driver/features/owner/documents_screen.dart';
import 'package:taxcy_driver/features/owner/people_screens.dart';
import 'package:taxcy_driver/features/owner/trips/create_trip_screen.dart';
import 'package:taxcy_driver/features/owner/trips/owner_trip_detail_screen.dart';
import 'package:taxcy_driver/features/owner/trip_schedule.dart';

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
    testWidgets('a photo and several files on one document, in order', (
      tester,
    ) async {
      final h = await owner(tester);
      // The bytes, as the camera and the real picker would have stored them.
      h.photoStore.photos['/photos/captured-document.jpg'] = Uint8List(1024);
      h.photoStore.photos['/photos/picked-document'] = Uint8List(2048);
      h.photoStore.photos['/photos/back'] = Uint8List(2048);
      h.pickFile = (kind) => [
        PickedFile(
          name: 'insurance.pdf',
          file: CapturedPhoto(
            id: 'picked-document',
            kind: kind,
            path: '/photos/picked-document',
            sha256: 'b' * 64,
            byteSize: 2048,
            contentType: 'application/pdf',
            capturedAt: DateTime.utc(2026, 10, 9, 3),
          ),
        ),
        PickedFile(
          name: 'rc-back.jpg',
          file: CapturedPhoto(
            id: 'back',
            kind: kind,
            path: '/photos/back',
            sha256: 'c' * 64,
            byteSize: 2048,
            capturedAt: DateTime.utc(2026, 10, 9, 3),
          ),
        ),
      ];
      await tester.pumpWidget(
        h.screen(const DocumentFormScreen(vehicleId: vehicleId)),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('document-take-photo')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('document-upload-file')));
      await settle(tester);
      expect(find.text('Photo 1'), findsOneWidget);
      expect(find.text('insurance.pdf'), findsOneWidget);
      expect(find.text('rc-back.jpg'), findsOneWidget);

      // Remove the PDF; the photo and the back stay, in order.
      await tester.tap(find.byKey(const ValueKey('document-file-remove-1')));
      await tester.pump();
      expect(find.text('insurance.pdf'), findsNothing);

      await tester.tap(find.byKey(const Key('document-expires')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('document-save')));
      await settle(tester);
      expect(h.owner.last('createDocument').args['mediaIds'], [
        'captured-document',
        'back',
      ]);
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
      expect(find.text('big-scan.pdf is larger than 15 MB.'), findsOneWidget);
    });

    testWidgets('a document with several files lists them all', (tester) async {
      final h = await owner(tester);
      const photo = '0199c7a2-0000-7000-8000-0000000009ab';
      const pdf = '0199c7a2-0000-7000-8000-0000000009ac';
      h.owner
        ..serveMediaUrls = true
        ..documentList = [
          {
            ...documentJson(),
            'mediaId': photo,
            'mediaContentType': 'image/jpeg',
            'files': [
              {'mediaId': photo, 'contentType': 'image/jpeg'},
              {'mediaId': pdf, 'contentType': 'application/pdf'},
            ],
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
          const ValueKey('document-menu-0199c7a2-0000-7000-8000-000000000d01'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('View files (2)'));
      await settle(tester);
      expect(find.byKey(const Key('document-files-dialog')), findsOneWidget);
      await tester.tap(find.text('Open'));
      await settle(tester);
      expect(h.openedUrls.single.toString(), 'https://files.test/$pdf');
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

  group('driver schedule', () {
    testWidgets('the driver page has a Schedule tab with their trips', (
      tester,
    ) async {
      final h = await owner(tester);
      const tripId = '0199c7a2-0000-7000-8000-0000000008ab';
      h.owner.tripsById
        ..clear()
        ..[tripId] = tripJson(
          id: tripId,
          status: 'assigned',
          scheduledStartAt: DateTime.now().toUtc(),
        );
      await tester.pumpWidget(
        h.screen(DriverScreen(driver: Driver.fromJson(driverJson()))),
      );
      await settle(tester);
      // Details first: name, pay and save stay where they were.
      expect(find.byKey(const Key('driver-save')), findsOneWidget);

      await tester.tap(find.byKey(const Key('driver-tab-schedule')));
      await settle(tester);
      final query = h.owner.last('trips').args;
      expect(query['driverId'], driverId);
      expect(query.containsKey('vehicleId'), isFalse);
      expect(query['overlapping'], 'true');
      expect(find.byKey(const Key('schedule-grid')), findsOneWidget);
      // Today is booked, so its trip is listed.
      expect(find.textContaining('Pune Station'), findsWidgets);
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
            body: TripSchedule(vehicleId: vehicleId, now: now),
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
