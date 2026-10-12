// Draws the app icon (the sign-in screen's white taxi on Fleet Sarthi blue)
// into every size the web and Android builds need. Not part of the test suite;
// re-run after changing the design:
//
//   flutter test tool/app_icons_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/app/theme.dart';

const _glyph = Icons.local_taxi;

/// How the glyph sits on the tile.
enum _Tile {
  /// A rounded tile with transparent corners (favicon, web, legacy Android).
  rounded,

  /// Full bleed, glyph inside the central safe circle (maskable web, iOS).
  fullBleed,

  /// The glyph alone on transparent: Android's adaptive foreground, which the
  /// launcher also tints for themed icons.
  glyphOnly,
}

Future<void> _draw(String path, int size, _Tile tile, double glyphScale) async {
  final s = size.toDouble();
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (tile != _Tile.glyphOnly) {
    final rect = Rect.fromLTWH(0, 0, s, s);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [TaxcyColors.blue600, TaxcyColors.blue800],
      ).createShader(rect);
    if (tile == _Tile.rounded) {
      final inset = s * 0.04;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.deflate(inset), Radius.circular(s * 0.22)),
        paint,
      );
    } else {
      canvas.drawRect(rect, paint);
    }
  }
  final text = TextPainter(
    textDirection: TextDirection.ltr,
    text: TextSpan(
      text: String.fromCharCode(_glyph.codePoint),
      style: TextStyle(
        fontFamily: _glyph.fontFamily,
        fontSize: s * glyphScale,
        height: 1,
        color: Colors.white,
      ),
    ),
  )..layout();
  text.paint(canvas, Offset((s - text.width) / 2, (s - text.height) / 2));
  final image = await recorder.endRecording().toImage(size, size);
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(png!.buffer.asUint8List());
}

void main() {
  testWidgets('draw app icons', (tester) async {
    await tester.runAsync(() async {
      final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
      final font = File(
        '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
      ).readAsBytesSync();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(Future.value(ByteData.sublistView(font)))).load();

      await _draw('web/favicon.png', 48, _Tile.rounded, 0.66);
      for (final size in [192, 512]) {
        await _draw('web/icons/Icon-$size.png', size, _Tile.rounded, 0.6);
        await _draw(
          'web/icons/Icon-maskable-$size.png',
          size,
          _Tile.fullBleed,
          0.5,
        );
      }

      const res = 'android/app/src/main/res';
      const densities = {
        'mdpi': 1.0,
        'hdpi': 1.5,
        'xhdpi': 2.0,
        'xxhdpi': 3.0,
        'xxxhdpi': 4.0,
      };
      for (final MapEntry(key: dpi, value: scale) in densities.entries) {
        await _draw(
          '$res/mipmap-$dpi/ic_launcher.png',
          (48 * scale).round(),
          _Tile.rounded,
          0.6,
        );
        // Adaptive icons are 108 dp; the launcher shows the middle 72 dp.
        await _draw(
          '$res/drawable-$dpi/ic_launcher_foreground.png',
          (108 * scale).round(),
          _Tile.glyphOnly,
          0.42,
        );
      }
    });
  });
}
