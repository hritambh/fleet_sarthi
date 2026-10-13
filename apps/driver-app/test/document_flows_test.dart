import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/api.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/core/api/owner_models.dart';
import 'package:taxcy_driver/features/driver/driver_documents_screen.dart';
import 'package:taxcy_driver/features/owner/documents_screen.dart';
import 'package:taxcy_driver/features/owner/people_screens.dart';
import 'package:taxcy_driver/features/owner/vehicles_screen.dart';

import 'support/fakes.dart';
import 'support/harness.dart';
import 'support/owner_fakes.dart';

/// A tall phone, so whole pages fit without scrolling.
Future<Harness> tall(
  WidgetTester tester, {
  List<String> roles = const ['owner'],
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = const Size(420, 2400);
  addTearDown(tester.view.reset);
  final h = await Harness.create(
    session: Session.fromJson(sessionJson(roles: roles)),
  );
  addTearDown(h.dispose);
  // Bytes for the camera photo, so it can be uploaded.
  h.photoStore.photos['/photos/captured-document.jpg'] = Uint8List(1024);
  h.photoStore.photos['/photos/picked-document'] = Uint8List(2048);
  return h;
}

/// Loads a page, then lets tab swipes and route transitions finish.
Future<void> idle(WidgetTester tester) async {
  await settle(tester);
  await tester.pump(const Duration(seconds: 1));
}

/// In the open form: a photo, a picked PDF and an expiry date, then one tap.
Future<void> fillAndSave(WidgetTester tester, {bool expiry = true}) async {
  await tester.tap(find.byKey(const Key('document-take-photo')));
  await settle(tester);
  await tester.tap(find.byKey(const Key('document-upload-file')));
  await settle(tester);
  if (expiry) {
    await tester.tap(find.byKey(const Key('document-expires')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }
  expect(find.text('Upload 2 files & save'), findsOneWidget);
  await tester.tap(find.byKey(const Key('document-save')));
  await idle(tester);
}

int uploads(Harness h) =>
    h.api.calls.where((c) => c.name == 'registerMedia').length;

void main() {
  group('one tap uploads and saves, and the list shows it', () {
    testWidgets('a vehicle document', (tester) async {
      final h = await tall(tester);
      h.owner.documentList = [];
      await tester.pumpWidget(
        h.screen(const VehicleDetailScreen(vehicleId: vehicleId)),
      );
      await idle(tester);
      await tester.tap(find.byKey(const Key('vehicle-add-document')));
      await idle(tester);
      await fillAndSave(tester);

      expect(uploads(h), 2);
      final body = h.owner.last('createDocument').args;
      expect(body['vehicleId'], vehicleId);
      expect(body['mediaIds'], ['captured-document', 'picked-document']);
      // Back on the vehicle, the new document is listed with its files.
      expect(find.byType(DocumentFormScreen), findsNothing);
      expect(find.text('Document saved'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey('document-files-0199c7a2-0000-7000-8000-00000000dd00'),
        ),
        findsOneWidget,
      );
    });

    testWidgets("a driver's document, from the owner's driver page", (
      tester,
    ) async {
      final h = await tall(tester);
      h.owner.documentList = [];
      await tester.pumpWidget(
        h.screen(
          DriverScreen(driver: Driver.fromJson(driverJson()), initialTab: 1),
        ),
      );
      await idle(tester);
      await tester.tap(find.byKey(const Key('driver-add-document')));
      await idle(tester);
      await fillAndSave(tester);

      final body = h.owner.last('createDocument').args;
      expect(body['driverId'], driverId);
      expect(body['docType'], 'driving_licence');
      expect(find.byType(DocumentFormScreen), findsNothing);
      expect(
        find.byKey(
          const ValueKey('document-files-0199c7a2-0000-7000-8000-00000000dd00'),
        ),
        findsOneWidget,
      );
    });

    testWidgets("the driver's own document, from the driver app", (
      tester,
    ) async {
      final h = await tall(tester, roles: ['driver']);
      h.me.documentList = [];
      await tester.pumpWidget(h.screen(const DriverDocumentsScreen()));
      await idle(tester);
      await tester.tap(find.byKey(const Key('my-document-add')));
      await idle(tester);
      await fillAndSave(tester);

      expect(h.me.last('submitDocument').args['mediaIds'], [
        'captured-document',
        'picked-document',
      ]);
      expect(find.byType(DocumentFormScreen), findsNothing);
      expect(find.text('Waiting for approval'), findsOneWidget);
    });

    testWidgets('renewing a vehicle document from its menu', (tester) async {
      final h = await tall(tester);
      await tester.pumpWidget(
        h.screen(const VehicleDetailScreen(vehicleId: vehicleId)),
      );
      await idle(tester);
      await tester.tap(
        find.byKey(
          const ValueKey('document-menu-0199c7a2-0000-7000-8000-000000000d01'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('document-renew')));
      await idle(tester);
      await fillAndSave(tester);
      expect(h.owner.last('renewDocument').args['mediaIds'], [
        'captured-document',
        'picked-document',
      ]);
      expect(find.byType(DocumentFormScreen), findsNothing);
    });
  });

  testWidgets('leaving with files asks before discarding them', (tester) async {
    final h = await tall(tester);
    await tester.pumpWidget(
      h.screen(const VehicleDetailScreen(vehicleId: vehicleId)),
    );
    await idle(tester);
    await tester.tap(find.byKey(const Key('vehicle-add-document')));
    await idle(tester);
    await tester.tap(find.byKey(const Key('document-take-photo')));
    await settle(tester);

    await tester.tap(find.byType(BackButton));
    await idle(tester);
    expect(find.byKey(const Key('document-discard-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const Key('document-keep-editing')));
    await idle(tester);
    expect(find.byType(DocumentFormScreen), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await idle(tester);
    await tester.tap(find.byKey(const Key('document-discard')));
    await idle(tester);
    expect(find.byType(DocumentFormScreen), findsNothing);
    expect(uploads(h), 0);
  });

  testWidgets('a failed save keeps the uploads and retries only the save', (
    tester,
  ) async {
    final h = await tall(tester);
    h.owner.documentList = [];
    await tester.pumpWidget(
      h.screen(const VehicleDetailScreen(vehicleId: vehicleId)),
    );
    await idle(tester);
    await tester.tap(find.byKey(const Key('vehicle-add-document')));
    await idle(tester);
    h.owner.failNext = ApiException(
      status: 0,
      code: 'NETWORK',
      message: 'offline',
    );
    await fillAndSave(tester);
    // Still on the form, both files uploaded.
    expect(find.byType(DocumentFormScreen), findsOneWidget);
    expect(find.text('Uploaded'), findsNWidgets(2));
    expect(uploads(h), 2);

    await tester.tap(find.byKey(const Key('document-save')));
    await idle(tester);
    expect(uploads(h), 2);
    expect(h.owner.calls.where((c) => c.name == 'createDocument').length, 2);
    expect(find.byType(DocumentFormScreen), findsNothing);
  });

  testWidgets('an open list picks up documents added elsewhere', (
    tester,
  ) async {
    final h = await tall(tester);
    h.owner.documentList = [];
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
    expect(find.text('No documents yet.'), findsOneWidget);

    // Added in another tab or by someone else.
    h.owner.documentList = [documentJson()];
    await tester.pump(const Duration(seconds: 31));
    await settle(tester);
    expect(
      find.byKey(
        const ValueKey('document-0199c7a2-0000-7000-8000-000000000d01'),
      ),
      findsOneWidget,
    );

    // And when the app comes back to the front.
    h.owner.documentList = [];
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await settle(tester);
    expect(find.text('No documents yet.'), findsOneWidget);
  });
}
