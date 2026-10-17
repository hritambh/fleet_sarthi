import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/models.dart';

import 'support/all_screens.dart';
import 'support/fakes.dart';
import 'support/harness.dart';

/// Every owner and driver screen renders on a small phone (360 px) in both
/// languages without overflowing or throwing.
void main() {
  for (final language in ['en', 'hi', 'kn', 'mr']) {
    for (final entry in AllScreens.owner.entries) {
      testWidgets('${entry.key} ($language)', (tester) async {
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = const Size(360, 1600);
        addTearDown(tester.view.reset);
        final h = await Harness.create(
          session: Session.fromJson(sessionJson(roles: ['owner', 'driver'])),
          language: language,
        );
        addTearDown(h.dispose);
        AllScreens.prepareOwner(h);
        await tester.pumpWidget(h.screen(entry.value));
        await settle(tester);
        // Any overflow or exception fails the test with the widget at fault.
      });
    }
  }

  for (final language in ['en', 'hi', 'kn', 'mr']) {
    for (final entry in AllScreens.driver.entries) {
      testWidgets('driver: ${entry.key} ($language)', (tester) async {
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = const Size(360, 1600);
        addTearDown(tester.view.reset);
        final h = await Harness.create(
          session: Session.fromJson(sessionJson()),
          language: language,
        );
        addTearDown(h.dispose);
        await AllScreens.prepareDriver(h);
        await tester.pumpWidget(h.screen(entry.value));
        await settle(tester);
        if (entry.key == 'end trip') {
          // A charge row and a split payment are the widest rows.
          await tester.tap(find.byIcon(Icons.add).first);
          await tester.tap(find.byIcon(Icons.call_split));
          await settle(tester);
        }
        // Any overflow or exception fails the test with the widget at fault.
      });
    }
  }
}
