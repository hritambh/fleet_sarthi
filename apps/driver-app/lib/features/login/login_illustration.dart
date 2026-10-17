import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../common/format.dart';

/// A line drawing for the wide login page: a cab on its way along a dotted
/// route to a map pin, with a stack of rupee coins and a plant, in the brand
/// blues. Drawn in code so it needs no asset and stays sharp at any size.
class LoginIllustration extends StatelessWidget {
  const LoginIllustration({super.key});

  static const _width = 560.0;
  static const _height = 420.0;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: _width / _height,
    // On the dark page: brighter lines and dim clouds.
    child: CustomPaint(
      painter: _ScenePainter(
        line: context.adaptive(_line, const Color(0xFF5B95F8)),
        cloud: context.adaptive(_pale, const Color(0xFF1B2A4D)),
      ),
    ),
  );
}

const _line = Color(0xFF1D3FBF);
const _ink = Color(0xFF1A2238);
const _pale = Color(0xFFDCEBFF);
const _plate = Color(0xFFFFD43B);

class _ScenePainter extends CustomPainter {
  const _ScenePainter({required this.line, required this.cloud});

  final Color line;
  final Color cloud;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..scale(
        size.width / LoginIllustration._width,
        size.height / LoginIllustration._height,
      )
      ..save();
    final stroke = Paint()
      ..color = line
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    Paint fill(Color c) => Paint()..color = c;

    // Soft clouds behind everything.
    for (final (x, y, w) in [(110.0, 70.0, 120.0), (300.0, 40.0, 90.0)]) {
      canvas
        ..drawOval(
          Rect.fromCenter(center: Offset(x, y), width: w, height: w * 0.32),
          fill(cloud),
        )
        ..drawOval(
          Rect.fromCenter(
            center: Offset(x + w * 0.18, y - w * 0.1),
            width: w * 0.5,
            height: w * 0.3,
          ),
          fill(cloud),
        );
    }

    // The road: a line with dashes under it.
    canvas.drawLine(const Offset(20, 362), const Offset(540, 362), stroke);
    for (var x = 40.0; x < 520; x += 44) {
      canvas.drawLine(Offset(x, 382), Offset(x + 22, 382), stroke);
    }

    // The dotted route from a start marker to the pin.
    final route = Path()
      ..moveTo(84, 168)
      ..cubicTo(170, 60, 310, 240, 418, 168);
    for (final metric in route.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 14) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + 7, metric.length)),
          stroke,
        );
      }
    }
    canvas
      ..drawCircle(const Offset(84, 168), 10, fill(Colors.white))
      ..drawCircle(const Offset(84, 168), 10, stroke)
      ..drawCircle(const Offset(84, 168), 3.5, fill(line));

    _pin(canvas, stroke);
    _cab(canvas, stroke);
    _coins(canvas, stroke);
    _plant(canvas, stroke);

    // A few sparkles.
    for (final (x, y) in [(500.0, 150.0), (40.0, 250.0), (330.0, 120.0)]) {
      canvas
        ..drawLine(Offset(x - 6, y), Offset(x + 6, y), stroke)
        ..drawLine(Offset(x, y - 6), Offset(x, y + 6), stroke);
    }
    canvas.restore();
  }

  void _pin(Canvas canvas, Paint stroke) {
    const centre = Offset(444, 118);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(444, 190), width: 64, height: 12),
      Paint()..color = _ink.withValues(alpha: 0.85),
    );
    final pin = Path()
      ..addOval(Rect.fromCircle(center: centre, radius: 36))
      ..moveTo(416, 142)
      ..lineTo(472, 142)
      ..lineTo(444, 186)
      ..close();
    canvas
      ..drawPath(pin, Paint()..color = line)
      ..drawCircle(centre, 14, Paint()..color = Colors.white);
  }

  void _cab(Canvas canvas, Paint stroke) {
    Paint fill(Color c) => Paint()..color = c;
    // Body and cabin.
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(120, 260, 290, 72),
      const Radius.circular(22),
    );
    final cabin = Path()
      ..moveTo(186, 262)
      ..lineTo(214, 206)
      ..lineTo(332, 206)
      ..lineTo(366, 262)
      ..close();
    canvas
      ..drawPath(cabin, fill(_pale))
      ..drawPath(cabin, stroke)
      ..drawRRect(body, fill(Colors.white))
      ..drawRRect(body, stroke);
    // Windows and the door seam.
    final left = Path()
      ..moveTo(200, 258)
      ..lineTo(222, 214)
      ..lineTo(268, 214)
      ..lineTo(268, 258)
      ..close();
    final right = Path()
      ..moveTo(280, 214)
      ..lineTo(326, 214)
      ..lineTo(352, 258)
      ..lineTo(280, 258)
      ..close();
    canvas
      ..drawPath(left, fill(Colors.white))
      ..drawPath(left, stroke)
      ..drawPath(right, fill(Colors.white))
      ..drawPath(right, stroke)
      ..drawLine(const Offset(274, 262), const Offset(274, 322), stroke)
      ..drawLine(const Offset(250, 282), const Offset(264, 282), stroke);
    // The roof light.
    final sign = RRect.fromRectAndRadius(
      const Rect.fromLTWH(246, 186, 56, 20),
      const Radius.circular(5),
    );
    canvas.drawRRect(sign, fill(_ink));
    final text = TextPainter(
      text: const TextSpan(
        text: 'TAXI',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    text.paint(canvas, Offset(274 - text.width / 2, 196 - text.height / 2));
    // Lights and the plate.
    canvas
      ..drawCircle(const Offset(398, 288), 7, fill(_plate))
      ..drawCircle(const Offset(398, 288), 7, stroke)
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(134, 298, 38, 16),
          const Radius.circular(3),
        ),
        fill(_plate),
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(134, 298, 38, 16),
          const Radius.circular(3),
        ),
        stroke,
      );
    // Wheels.
    for (final x in const [180.0, 350.0]) {
      canvas
        ..drawCircle(Offset(x, 336), 30, fill(_ink))
        ..drawCircle(Offset(x, 336), 12, fill(Colors.white))
        ..drawCircle(Offset(x, 336), 12, stroke);
    }
  }

  void _coins(Canvas canvas, Paint stroke) {
    Paint fill(Color c) => Paint()..color = c;
    for (var i = 0; i < 3; i++) {
      final y = 346.0 - i * 13;
      final coin = Rect.fromCenter(
        center: Offset(70, y),
        width: 58,
        height: 18,
      );
      canvas
        ..drawOval(coin, fill(i == 2 ? _plate : _pale))
        ..drawOval(coin, stroke);
    }
    final rupee = TextPainter(
      text: const TextSpan(
        text: '₹',
        style: TextStyle(
          color: _ink,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    rupee.paint(canvas, Offset(70 - rupee.width / 2, 320 - rupee.height / 2));
  }

  void _plant(Canvas canvas, Paint stroke) {
    Paint fill(Color c) => Paint()..color = c;
    Path leaf(double tipX, double tipY) => Path()
      ..moveTo(508, 330)
      ..quadraticBezierTo((508 + tipX) / 2 - 14, (330 + tipY) / 2, tipX, tipY)
      ..quadraticBezierTo(
        (508 + tipX) / 2 + 14,
        (330 + tipY) / 2 + 6,
        508,
        330,
      );
    for (final tip in const [(478.0, 288.0), (510.0, 272.0), (540.0, 292.0)]) {
      final path = leaf(tip.$1, tip.$2);
      canvas
        ..drawPath(path, fill(_pale))
        ..drawPath(path, stroke);
    }
    final pot = Path()
      ..moveTo(484, 330)
      ..lineTo(532, 330)
      ..lineTo(524, 362)
      ..lineTo(492, 362)
      ..close();
    canvas
      ..drawPath(pot, fill(Colors.white))
      ..drawPath(pot, stroke);
  }

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) =>
      oldDelegate.line != line || oldDelegate.cloud != cloud;
}

/// The wide login page's right-hand side: the illustration, centred, with a
/// handwritten line under it.
class LoginIllustrationPanel extends StatelessWidget {
  const LoginIllustrationPanel({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LoginIllustration(),
            const SizedBox(height: 8),
            Text(
              context.l10n.loginTagline,
              key: const Key('login-tagline'),
              textAlign: TextAlign.center,
              style: accentStyle(
                context,
                TextStyle(fontSize: 22, color: context.tc.blue700),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
