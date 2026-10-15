import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/app/app.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/core/api/owner_models.dart';
import 'package:taxcy_driver/features/driver/driver_documents_screen.dart';
import 'package:taxcy_driver/features/driver/driver_profile_screen.dart';
import 'package:taxcy_driver/features/driver/driver_trips_screen.dart';
import 'package:taxcy_driver/features/owner/documents_screen.dart';
import 'package:taxcy_driver/features/owner/people_screens.dart';

import 'support/fakes.dart';
import 'support/harness.dart';
import 'support/me_fakes.dart';
import 'support/owner_fakes.dart';

/// A tall phone, so whole pages fit without scrolling.
Future<Harness> tall(
  WidgetTester tester, {
  List<String> roles = const ['driver'],
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(420, 2400);
  addTearDown(tester.view.reset);
  final h = await Harness.create(
    session: Session.fromJson(sessionJson(roles: roles)),
  );
  addTearDown(h.dispose);
  return h;
}

/// Loads the tab, then lets the swipe between tabs finish.
Future<void> switchTab(WidgetTester tester) async {
  await settle(tester);
  await tester.pump(const Duration(seconds: 1));
}

/// 13 Oct 2026, 11:30 IST.
final now = DateTime.utc(2026, 10, 13, 6);

void main() {
  testWidgets('the driver lands on Home with Trips, Documents and Profile', (
    tester,
  ) async {
    final h = await tall(tester);
    await tester.pumpWidget(h.wrap(const TaxcyDriverApp()));
    await settle(tester);
    expect(find.byKey(const Key('driver-nav')), findsOneWidget);
    // Home is the existing day view.
    // One way to start a new trip: the quick action, not a floating button.
    expect(find.byKey(const Key('driver-action-new-trip')), findsOneWidget);
    expect(find.byKey(const Key('new-trip')), findsNothing);
    // Likewise one way to log fuel: the quick action, not an app-bar icon.
    expect(find.byKey(const Key('driver-action-fuel')), findsOneWidget);
    expect(find.byTooltip('Log fuel'), findsNothing);

    await tester.tap(find.byKey(const Key('driver-nav-trips')));
    await settle(tester);
    expect(find.byType(DriverTripsScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('driver-nav-docs')));
    await settle(tester);
    expect(find.byType(DriverDocumentsScreen), findsOneWidget);
    expect(h.me.calls.map((c) => c.name), contains('documents'));

    await tester.tap(find.byKey(const Key('driver-nav-profile')));
    await settle(tester);
    expect(find.byType(DriverProfileScreen), findsOneWidget);
  });

  group('trips', () {
    testWidgets('assigned trips come from the phone', (tester) async {
      final h = await tall(tester);
      await h.engine.cacheTrip(
        Trip.fromJson(tripJson(id: 'a0000000-0000-4000-8000-000000000001')),
      );
      await h.engine.cacheTrip(
        Trip.fromJson(
          tripJson(id: 'a0000000-0000-4000-8000-000000000002', status: 'ended'),
        ),
      );
      await tester.pumpWidget(h.screen(DriverTripsScreen(now: now)));
      await settle(tester);
      expect(
        find.byKey(
          const ValueKey('driver-trip-a0000000-0000-4000-8000-000000000001'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          const ValueKey('driver-trip-a0000000-0000-4000-8000-000000000002'),
        ),
        findsNothing,
      );
    });

    testWidgets('past trips are fetched a month at a time', (tester) async {
      final h = await tall(tester);
      const pastId = 'b0000000-0000-4000-8000-000000000001';
      h.me.tripList = [
        tripJson(
          id: pastId,
          status: 'settled',
          scheduledStartAt: DateTime.utc(2026, 10, 2, 4),
        ),
        // Still to come: not a past trip.
        tripJson(
          id: 'b0000000-0000-4000-8000-000000000002',
          scheduledStartAt: DateTime.utc(2026, 10, 20, 4),
        ),
      ];
      await tester.pumpWidget(h.screen(DriverTripsScreen(now: now)));
      await settle(tester);
      await tester.tap(find.byKey(const Key('driver-tab-past')));
      await switchTab(tester);
      // October in IST.
      expect(h.me.last('tripsBetween').args, {
        'from': '2026-09-30T18:30:00.000Z',
        'to': '2026-10-31T18:30:00.000Z',
      });
      expect(find.text('October 2026'), findsOneWidget);
      expect(find.byKey(const ValueKey('driver-trip-$pastId')), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey('driver-trip-b0000000-0000-4000-8000-000000000002'),
        ),
        findsNothing,
      );
      // Not on the phone: a summary instead of the full trip.
      await tester.tap(find.byKey(const ValueKey('driver-trip-$pastId')));
      await settle(tester);
      expect(find.byKey(const Key('trip-summary')), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await settle(tester);

      await tester.tap(find.byKey(const Key('past-prev')));
      await settle(tester);
      expect(find.text('September 2026'), findsOneWidget);
      expect(
        h.me.last('tripsBetween').args['from'],
        '2026-08-31T18:30:00.000Z',
      );
    });

    testWidgets('the schedule shows the driver\'s own trips', (tester) async {
      final h = await tall(tester);
      h.me.tripList = [
        tripJson(
          id: 'c0000000-0000-4000-8000-000000000001',
          scheduledStartAt: DateTime.utc(2026, 10, 15, 4),
        ),
      ];
      await tester.pumpWidget(h.screen(DriverTripsScreen(now: now)));
      await settle(tester);
      await tester.tap(find.byKey(const Key('driver-tab-schedule')));
      await switchTab(tester);
      expect(find.byKey(const Key('schedule-grid')), findsOneWidget);
      expect(h.me.calls.map((c) => c.name), contains('tripsBetween'));
      await tester.tap(find.byKey(const ValueKey('schedule-day-2026-10-15')));
      await tester.pump();
      expect(
        find.byKey(
          const ValueKey('driver-trip-c0000000-0000-4000-8000-000000000001'),
        ),
        findsOneWidget,
      );
    });
  });

  group('documents', () {
    testWidgets('pending and rejected uploads are labelled', (tester) async {
      final h = await tall(tester);
      h.me.documentList = [
        myDocumentJson(),
        myDocumentJson(
          id: '0199c7a2-0000-7000-8000-000000000e02',
          docType: 'aadhaar',
          reviewStatus: 'pending',
          expiresOn: null,
        ),
        myDocumentJson(
          id: '0199c7a2-0000-7000-8000-000000000e03',
          docType: 'pan',
          reviewStatus: 'rejected',
          reviewNote: 'Photo is blurry',
          expiresOn: null,
        ),
      ];
      await tester.pumpWidget(h.screen(const DriverDocumentsScreen()));
      await settle(tester);
      expect(find.text('Waiting for approval'), findsOneWidget);
      expect(find.textContaining('Rejected: Photo is blurry'), findsOneWidget);
      expect(find.textContaining('No expiry'), findsNWidgets(2));
    });

    testWidgets('adding one sends it for approval with its files', (
      tester,
    ) async {
      final h = await tall(tester);
      h.photoStore.photos['/photos/captured-document.jpg'] = Uint8List(1024);
      await tester.pumpWidget(h.screen(const DriverDocumentsScreen()));
      await settle(tester);
      await tester.tap(find.byKey(const Key('my-document-add')));
      await settle(tester);
      // Driver types only.
      await tester.tap(find.text('Driving licence').last);
      await tester.pumpAndSettle();
      expect(find.text('Aadhaar card').last, findsOneWidget);
      expect(find.text('Insurance'), findsNothing);
      await tester.tap(find.text('Aadhaar card').last);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('document-number')),
        '2341 2341 2346',
      );
      await tester.tap(find.byKey(const Key('document-take-photo')));
      await settle(tester);
      // Aadhaar needs no expiry date.
      await tester.tap(find.byKey(const Key('document-save')));
      await settle(tester);
      final body = h.me.last('submitDocument').args;
      expect(body['docType'], 'aadhaar');
      expect(body['number'], '234123412346');
      expect(body['mediaIds'], ['captured-document']);
      expect(body.containsKey('expiresOn'), isFalse);
      expect(find.byType(DriverDocumentsScreen), findsOneWidget);
      expect(find.text('Waiting for approval'), findsOneWidget);
    });

    testWidgets('a licence needs an expiry date', (tester) async {
      final h = await tall(tester);
      await tester.pumpWidget(h.screen(const DocumentFormScreen(mine: true)));
      await settle(tester);
      await tester.tap(find.byKey(const Key('document-save')));
      await settle(tester);
      expect(h.me.calls.where((c) => c.name == 'submitDocument'), isEmpty);
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('renewing goes to the owner too', (tester) async {
      final h = await tall(tester);
      await tester.pumpWidget(h.screen(const DriverDocumentsScreen()));
      await settle(tester);
      await tester.tap(
        find.byKey(
          const ValueKey('document-menu-0199c7a2-0000-7000-8000-000000000e01'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('document-renew')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('document-expires')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('document-save')));
      await settle(tester);
      expect(
        h.me.last('renewDocument').args['id'],
        '0199c7a2-0000-7000-8000-000000000e01',
      );
    });
  });

  group('profile', () {
    testWidgets('shows the cabs and saves the edited details', (tester) async {
      final h = await tall(tester);
      h.photoStore.photos['/photos/captured-other.jpg'] = Uint8List(1024);
      await tester.pumpWidget(
        h.screen(const Scaffold(body: DriverProfileScreen())),
      );
      await settle(tester);
      expect(find.text('Ramesh Kumar'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('profile-cab-$vehicleId')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('profile-edit')));
      await settle(tester);
      await tester.enterText(
        find.byKey(const Key('profile-name-field')),
        'Ramesh K. Yadav',
      );
      await tester.enterText(
        find.byKey(const Key('profile-email')),
        'ramesh@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('profile-address')),
        '12 MG Road, Pune',
      );
      await tester.enterText(
        find.byKey(const Key('profile-emergency-name')),
        'Sita Kumar',
      );
      await tester.enterText(
        find.byKey(const Key('profile-emergency-phone')),
        '9876543210',
      );
      await tester.tap(find.byKey(const Key('profile-photo-take')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('profile-save')));
      await settle(tester);
      final body = h.me.last('updateProfile').args;
      expect(body['name'], 'Ramesh K. Yadav');
      expect(body['email'], 'ramesh@example.com');
      expect(body['address'], '12 MG Road, Pune');
      expect(body['emergencyContactName'], 'Sita Kumar');
      expect(body['emergencyContactPhone'], '+919876543210');
      expect(body['photoMediaId'], 'captured-other');
      expect((await h.sessions.load())?.name, 'Ramesh K. Yadav');
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Profile saved'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('profile-email-value')),
          matching: find.text('ramesh@example.com'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a bad email is marked and nothing is saved', (tester) async {
      final h = await tall(tester);
      await tester.pumpWidget(
        h.screen(const Scaffold(body: DriverProfileScreen())),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('profile-edit')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('profile-email')), 'ramesh@');
      await tester.tap(find.byKey(const Key('profile-save')));
      await settle(tester);
      expect(find.text('Enter a valid email address'), findsOneWidget);
      expect(h.me.calls.where((c) => c.name == 'updateProfile'), isEmpty);
    });

    testWidgets('changes the mobile number with a code', (tester) async {
      final h = await tall(tester);
      await tester.pumpWidget(
        h.screen(const Scaffold(body: DriverProfileScreen())),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('profile-change-phone')));
      await settle(tester);
      await tester.enterText(
        find.byKey(const Key('phone-field')),
        '9876543210',
      );
      await tester.tap(find.byKey(const Key('change-phone-submit')));
      await settle(tester);
      expect(h.me.last('requestPhoneOtp').args['phone'], '+919876543210');
      await tester.enterText(find.byKey(const Key('code-field')), '123456');
      await tester.tap(find.byKey(const Key('change-phone-submit')));
      await settle(tester);
      expect(h.me.last('changePhone').args, {
        'phone': '+919876543210',
        'code': '123456',
      });
      expect((await h.sessions.load())?.phone, '+919876543210');
      expect(find.text('Mobile number changed'), findsOneWidget);
    });
  });

  group('owner review', () {
    testWidgets("the owner sees and edits a driver's personal details", (
      tester,
    ) async {
      final h = await tall(tester, roles: ['owner']);
      h.owner.driverList = [
        {
          ...driverJson(),
          'email': 'ramesh@example.com',
          'dateOfBirth': '1990-05-20',
        },
      ];
      await tester.pumpWidget(
        h.screen(DriverScreen(driver: Driver.fromJson(driverJson()))),
      );
      await settle(tester);
      expect(find.byKey(const Key('driver-personal')), findsOneWidget);
      expect(find.text('ramesh@example.com'), findsOneWidget);
      await tester.tap(find.byKey(const Key('driver-edit-details')));
      await settle(tester);
      await tester.enterText(
        find.byKey(const Key('profile-address')),
        '12 MG Road, Pune',
      );
      await tester.tap(find.byKey(const Key('profile-save')));
      await settle(tester);
      final body = h.owner.last('updateDriverProfile').args;
      expect(body['id'], driverId);
      expect(body['address'], '12 MG Road, Pune');
      expect(body['email'], 'ramesh@example.com');
      expect(body['dateOfBirth'], '1990-05-20');
    });

    testWidgets('a driver upload can be approved or rejected', (tester) async {
      final h = await tall(tester, roles: ['owner']);
      const pending = '0199c7a2-0000-7000-8000-000000000e05';
      h.owner.documentList = [
        {
          ...myDocumentJson(
            id: pending,
            docType: 'aadhaar',
            reviewStatus: 'pending',
            expiresOn: null,
          ),
        },
      ];
      await tester.pumpWidget(
        h.screen(
          DriverScreen(driver: Driver.fromJson(driverJson()), initialTab: 1),
        ),
      );
      await settle(tester);
      expect(find.textContaining('Added by driver'), findsOneWidget);
      expect(find.text('Waiting for approval'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('document-menu-$pending')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('document-approve')));
      await settle(tester);
      expect(h.owner.last('approveDocument').args['id'], pending);

      await tester.tap(find.byKey(const ValueKey('document-menu-$pending')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('document-reject')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Photo is blurry');
      await tester.tap(find.text('Reject').last);
      await settle(tester);
      expect(h.owner.last('rejectDocument').args, {
        'id': pending,
        'note': 'Photo is blurry',
      });
    });
  });
}
