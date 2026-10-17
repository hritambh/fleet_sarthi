import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/app/theme.dart';

/// The colour of the pixel at ([x], [y]) of the PNG at [path].
Future<Color> pixel(String path, int x, int y) async {
  final codec = await ui.instantiateImageCodec(File(path).readAsBytesSync());
  final image = (await codec.getNextFrame()).image;
  final bytes = (await image.toByteData())!;
  final i = (y * image.width + x) * 4;
  return Color.fromARGB(
    bytes.getUint8(i + 3),
    bytes.getUint8(i),
    bytes.getUint8(i + 1),
    bytes.getUint8(i + 2),
  );
}

/// Close enough to [expected] (the gradient blends towards blue800).
Matcher near(Color expected) => predicate<Color>(
  (c) =>
      (c.r - expected.r).abs() < 0.06 &&
      (c.g - expected.g).abs() < 0.06 &&
      (c.b - expected.b).abs() < 0.06 &&
      c.a == 1,
  'close to $expected',
);

void main() {
  // Android and iOS show the same icon (tool/app_icons_test.dart draws both):
  // the Fleet Sarthi blue tile, never Flutter's default logo.
  testWidgets('iOS and Android have the Fleet Sarthi icon', (tester) async {
    await tester.runAsync(() async {
      const ios = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
      final icons = Directory(ios)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.png'))
          .toList();
      expect(icons, hasLength(15));
      for (final icon in icons) {
        expect(await pixel(icon.path, 0, 0), near(TaxcyColors.blue600));
      }
      // Android's launcher icon is the same tile, with rounded corners.
      const android = 'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png';
      expect(await pixel(android, 30, 30), near(TaxcyColors.blue600));
    });
  });
}
