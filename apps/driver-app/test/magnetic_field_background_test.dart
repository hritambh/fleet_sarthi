import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/features/common/magnetic_field_background.dart';

Widget field({
  required VoidCallback onPressed,
  bool reduceMotion = false,
  bool visible = true,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(
      size: const Size(800, 600),
      disableAnimations: reduceMotion,
    ),
    child: TickerMode(
      enabled: visible,
      child: Scaffold(
        body: MagneticFieldBackground(
          child: Center(
            child: ElevatedButton(
              onPressed: onPressed,
              child: const Text('Go'),
            ),
          ),
        ),
      ),
    ),
  ),
);

/// Lets a few frames run (the field animates, so pumpAndSettle never would).
Future<void> frames(WidgetTester tester, {int count = 30}) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('content above the field still gets its taps', (tester) async {
    var taps = 0;
    await tester.pumpWidget(field(onPressed: () => taps++));
    await tester.tap(find.text('Go'));
    await frames(tester);
    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hover and a ripple animate without errors', (tester) async {
    await tester.pumpWidget(field(onPressed: () {}));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(100, 100));
    await mouse.moveTo(const Offset(300, 200));
    await frames(tester);
    await tester.tapAt(const Offset(200, 400));
    await frames(tester, count: 120);
    expect(tester.takeException(), isNull);

    // Once settled it stops asking for a frame every vsync, even with the
    // pointer still resting on it: only the slow resting wave remains, on a
    // 50 ms timer.
    await frames(tester, count: 60);
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.binding.hasScheduledFrame, isFalse);
    await mouse.removePointer();
  });

  testWidgets('reduced motion settles and stops animating', (tester) async {
    await tester.pumpWidget(field(onPressed: () {}, reduceMotion: true));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(300, 200));
    await mouse.moveTo(const Offset(320, 220));
    await tester.tapAt(const Offset(200, 400)); // no ripple with reduced motion
    await mouse.removePointer();
    await frames(tester, count: 120);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a hidden field produces no frames', (tester) async {
    await tester.pumpWidget(field(onPressed: () {}, visible: false));
    await frames(tester, count: 5);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
