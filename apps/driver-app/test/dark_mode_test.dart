import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/models.dart';

import 'support/all_screens.dart';
import 'support/contrast.dart';
import 'support/fakes.dart';
import 'support/harness.dart';

/// Every owner and driver screen in the dark theme, on a phone and (owner
/// screens) on the desktop: all text and icons readable against what's
/// behind them, and no light-theme white cards left over.
void main() {
  Future<void> check(WidgetTester tester, String name) async {
    final problems = [
      for (final p in lowContrast(tester)) 'low contrast: $p',
      for (final p in brightSurfaces(tester)) 'light surface: $p',
    ];
    expect(problems, isEmpty, reason: '$name in the dark theme');
  }

  for (final (layout, size) in [
    ('phone', const Size(390, 1600)),
    ('desktop', const Size(1400, 1100)),
  ]) {
    for (final entry in AllScreens.owner.entries) {
      testWidgets('${entry.key} ($layout)', (tester) async {
        tester.view
          ..devicePixelRatio = 1
          ..physicalSize = size;
        addTearDown(tester.view.reset);
        final h = await Harness.create(
          session: Session.fromJson(sessionJson(roles: ['owner', 'driver'])),
        );
        addTearDown(h.dispose);
        AllScreens.prepareOwner(h);
        await tester.pumpWidget(
          h.screen(entry.value, brightness: Brightness.dark),
        );
        await settle(tester);
        await check(tester, entry.key);
      });
    }
  }

  for (final entry in AllScreens.driver.entries) {
    testWidgets('driver: ${entry.key}', (tester) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(390, 1600);
      addTearDown(tester.view.reset);
      final h = await Harness.create(session: Session.fromJson(sessionJson()));
      addTearDown(h.dispose);
      await AllScreens.prepareDriver(h);
      await tester.pumpWidget(
        h.screen(entry.value, brightness: Brightness.dark),
      );
      await settle(tester);
      await check(tester, entry.key);
    });
  }
}
