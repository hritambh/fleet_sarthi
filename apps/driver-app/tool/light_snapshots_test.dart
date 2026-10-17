// Renders every owner and driver screen in the app's theme and writes each
// as a PNG to $SNAPSHOT_DIR, to compare runs pixel for pixel (e.g. that a
// theme change left the light theme exactly as it was). Not part of the
// test suite:
//
//   SNAPSHOT_DIR=/tmp/before flutter test tool/light_snapshots_test.dart
//   (optional: SNAPSHOT_BRIGHTNESS=dark)
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/models.dart';

import '../test/support/all_screens.dart';
import '../test/support/fakes.dart';
import '../test/support/harness.dart';

void main() {
  final dir = Platform.environment['SNAPSHOT_DIR']!;
  final brightness = Platform.environment['SNAPSHOT_BRIGHTNESS'] == 'dark'
      ? Brightness.dark
      : Brightness.light;
  const boundary = Key('snapshot');

  Future<void> save(WidgetTester tester, String name) async {
    await tester.runAsync(() async {
      final render =
          tester.renderObject(find.byKey(boundary)) as RenderRepaintBoundary;
      final image = await render.toImage();
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      File('$dir/${name.replaceAll(RegExp('[^a-z0-9]+'), '-')}.png')
        ..createSync(recursive: true)
        ..writeAsBytesSync(png!.buffer.asUint8List());
    });
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
          RepaintBoundary(
            key: boundary,
            child: h.screen(entry.value, brightness: brightness),
          ),
        );
        await settle(tester);
        await save(tester, '${entry.key} $layout');
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
        RepaintBoundary(
          key: boundary,
          child: h.screen(entry.value, brightness: brightness),
        ),
      );
      await settle(tester);
      await save(tester, 'driver ${entry.key}');
    });
  }
}
