import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Tunables. Lengths in logical px, times in seconds, angles in radians.
const _dashLength = 10.0; // dash length at rest
const _strokeWidth = 1.2; // dash thickness
const _restAngle = -math.pi / 6; // the shared slight diagonal at rest
const _breathAmplitude = 0.10; // how far the resting wave tilts dashes
const _breathPeriod = 8.0; // one wave cycle
const _breathWavelength =
    1100.0; // distance between wave crests across the grid
const _maxStretch = 0.4; // dashes near the pointer grow up to 1 + this
const _restOpacity = 0.25; // neutral dash opacity
const _accentOpacity = 0.7; // dash opacity at full accent
const _followTau = 0.04; // easing towards a stronger target (~120 ms to settle)
const _relaxTau = 0.2; // easing back to rest (~600 ms to settle)
const _ringSpeed = 400.0; // ripple expansion speed, px/s
const _ringLife = 1.6; // ripple lifetime
const _ringBand = 28.0; // width of the band a ripple disturbs
const _ringFlash = 0.8; // how far a passing ripple pushes colour to the accent
const _maxRings = 3; // older ripples are dropped
const _colorBuckets = 6; // colour steps; one draw call each
const _idleFrame = Duration(milliseconds: 50); // resting wave updates at 20 fps
const _settledAngle =
    0.03; // below this the field counts as settled (idle mode)

/// A quiet, living background: a grid of short dashes that slowly "breathe",
/// turn towards the pointer like iron filings around a magnet, and ripple
/// when tapped. It sits behind [child] without taking its taps or gestures.
///
/// With reduced motion (MediaQuery.disableAnimations) it draws the resting
/// grid only, with a hover tint but no movement or ripples. Its animation
/// pauses when hidden (TickerMode off) and drops to 20 fps while idle.
class MagneticFieldBackground extends StatefulWidget {
  const MagneticFieldBackground({
    super.key,
    this.child,
    this.accentColor,
    this.spacing = 28,
    this.influenceRadius = 160,
    this.enableRipples = true,
  });

  /// Content rendered above the field.
  final Widget? child;

  /// Colour the dashes blend towards near the pointer (default indigo).
  final Color? accentColor;

  /// Distance between dashes.
  final double spacing;

  /// How far from the pointer dashes react.
  final double influenceRadius;

  final bool enableRipples;

  @override
  State<MagneticFieldBackground> createState() =>
      _MagneticFieldBackgroundState();
}

class _MagneticFieldBackgroundState extends State<MagneticFieldBackground>
    with SingleTickerProviderStateMixin {
  // Two clocks: the ticker (every frame) while something is moving, and a
  // slow timer for the resting wave. An idle field never asks for a frame
  // per vsync, which on the web would cost a full composite each time.
  late final Ticker _ticker = createTicker(_tick);
  Timer? _breath;
  final _breathClock = Stopwatch();
  final _field = _FieldSimulation();
  final _repaint = _Repaint();
  Duration _lastTick = Duration.zero;
  Size? _laidOutSize;
  double? _laidOutSpacing;
  bool _motion = true;
  bool _visible = true;
  Offset? _downAt;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _motion = !MediaQuery.disableAnimationsOf(context);
    // TickerMode also mutes the ticker; the breathing timer checks it here.
    _visible = TickerMode.of(context);
    if (!_motion) _field.clearRings();
    _wake();
  }

  @override
  void dispose() {
    _breath?.cancel();
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  /// Runs the ticker (every frame) until the field settles again.
  void _wake() {
    _breath?.cancel();
    _breath = null;
    if (_ticker.isActive) return;
    _lastTick = Duration.zero;
    _ticker.start();
  }

  void _tick(Duration elapsed) {
    final dt = math.min((elapsed - _lastTick).inMicroseconds / 1e6, 0.05);
    _lastTick = elapsed;
    final busy = _field.step(
      dt,
      radius: widget.influenceRadius,
      motion: _motion,
    );
    _repaint.ping();
    if (!busy) {
      _ticker.stop();
      _scheduleBreath();
    }
  }

  /// While settled, only the slow wave moves: a few updates a second do.
  void _scheduleBreath() {
    if (!_motion || !_visible) return;
    _breathClock
      ..reset()
      ..start();
    _breath = Timer(_idleFrame, () {
      final dt = math.min(_breathClock.elapsedMicroseconds / 1e6, 0.25);
      _field.step(dt, radius: widget.influenceRadius, motion: _motion);
      _repaint.ping();
      _scheduleBreath();
    });
  }

  void _pointAt(Offset? at) {
    _field.magnet = at;
    _wake();
  }

  void _onDown(PointerDownEvent e) {
    _downAt = e.localPosition;
    if (e.kind != PointerDeviceKind.mouse) _pointAt(e.localPosition);
  }

  void _onMove(PointerMoveEvent e) => _pointAt(e.localPosition);

  void _onUp(PointerUpEvent e) {
    final down = _downAt;
    _downAt = null;
    final tapped =
        down != null && (e.localPosition - down).distance < kTouchSlop;
    if (tapped && widget.enableRipples && _motion) {
      _field.addRing(e.localPosition);
    }
    // A finger lifting takes the magnet with it; a mouse keeps hovering.
    _pointAt(e.kind == PointerDeviceKind.mouse ? e.localPosition : null);
  }

  void _onCancel(PointerCancelEvent e) {
    _downAt = null;
    if (e.kind != PointerDeviceKind.mouse) _pointAt(null);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = widget.accentColor ?? const Color(0xFF6366F1);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (size != _laidOutSize || widget.spacing != _laidOutSpacing) {
          _laidOutSize = size;
          _laidOutSpacing = widget.spacing;
          _field.layout(size, widget.spacing, motion: _motion);
        }
        return Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: _onDown,
          onPointerMove: _onMove,
          onPointerUp: _onUp,
          onPointerCancel: _onCancel,
          child: MouseRegion(
            opaque: false,
            onHover: (e) => _pointAt(e.localPosition),
            onExit: (_) => _pointAt(null),
            child: Stack(
              children: [
                // The gradient never changes, so it stays out of the layer
                // that repaints every frame.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          scheme.surfaceContainerLow,
                          Color.lerp(
                            scheme.surfaceContainerLow,
                            scheme.surfaceContainerHigh,
                            0.45,
                          )!,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: RepaintBoundary(
                      child: CustomPaint(
                        painter: _FieldPainter(
                          field: _field,
                          repaint: _repaint,
                          neutral: scheme.onSurfaceVariant,
                          accent: accent,
                        ),
                      ),
                    ),
                  ),
                ),
                ?widget.child,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tells the painter a new frame is ready.
class _Repaint extends ChangeNotifier {
  void ping() => notifyListeners();
}

/// Per-dash state in flat arrays (no per-dash objects), stepped once a frame.
class _FieldSimulation {
  int count = 0;
  Float32List xs = Float32List(0);
  Float32List ys = Float32List(0);
  Float32List angles = Float32List(0);
  Float32List lengths = Float32List(0); // 1 = rest length
  Float32List colors = Float32List(0); // 0 = neutral, 1 = full accent

  /// Line endpoints for drawRawPoints, one region of count * 4 per bucket.
  Float32List points = Float32List(0);
  final bucketSizes = Int32List(_colorBuckets);

  /// Ripples as (x, y, age) triples, oldest first.
  final _rings = Float32List(_maxRings * 3);
  int _ringCount = 0;

  Offset? magnet;
  double _time = 0;

  void layout(Size size, double spacing, {required bool motion}) {
    final cols = (size.width / spacing).floor() + 1;
    final rows = (size.height / spacing).floor() + 1;
    final left = (size.width - (cols - 1) * spacing) / 2;
    final top = (size.height - (rows - 1) * spacing) / 2;
    count = cols * rows;
    xs = Float32List(count);
    ys = Float32List(count);
    angles = Float32List(count);
    lengths = Float32List(count)..fillRange(0, count, 1);
    colors = Float32List(count);
    points = Float32List(count * 4 * _colorBuckets);
    var i = 0;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++, i++) {
        xs[i] = left + c * spacing;
        ys[i] = top + r * spacing;
        angles[i] = _rest(i, motion);
      }
    }
  }

  void addRing(Offset at) {
    if (_ringCount == _maxRings) {
      _rings.setRange(0, (_maxRings - 1) * 3, _rings, 3); // drop the oldest
      _ringCount--;
    }
    final at3 = _ringCount * 3;
    _rings[at3] = at.dx;
    _rings[at3 + 1] = at.dy;
    _rings[at3 + 2] = 0;
    _ringCount++;
  }

  void clearRings() => _ringCount = 0;

  double _rest(int i, bool motion) {
    if (!motion) return _restAngle;
    final phase =
        _time / _breathPeriod - (xs[i] + ys[i] * 0.6) / _breathWavelength;
    return _restAngle + _breathAmplitude * math.sin(2 * math.pi * phase);
  }

  /// Advances the field by [dt] seconds. Returns whether anything is still
  /// moving (ripples, or dashes easing towards a target); a pointer resting
  /// over settled dashes isn't.
  bool step(double dt, {required double radius, required bool motion}) {
    _time += dt;
    _ageRings(dt);
    final follow = 1 - math.exp(-dt / _followTau);
    final relax = 1 - math.exp(-dt / _relaxTau);
    final m = magnet;
    final r2 = radius * radius;
    var busy = _ringCount > 0;
    for (var i = 0; i < count; i++) {
      final x = xs[i];
      final y = ys[i];
      var target = _rest(i, motion);
      var stretch = 1.0;
      var tint = 0.0;
      if (m != null) {
        final dx = m.dx - x;
        final dy = m.dy - y;
        final d2 = dx * dx + dy * dy;
        if (d2 < r2) {
          final t = 1 - math.sqrt(d2) / radius;
          final w = t * t * (3 - 2 * t); // smoothstep falloff
          tint = w;
          if (motion) {
            target += _wrap(math.atan2(dy, dx) - target) * w;
            stretch += _maxStretch * w;
          }
        }
      }
      for (var k = 0; k < _ringCount; k++) {
        final dx = x - _rings[k * 3];
        final dy = y - _rings[k * 3 + 1];
        final age = _rings[k * 3 + 2];
        final off = (math.sqrt(dx * dx + dy * dy) - age * _ringSpeed).abs();
        if (off < _ringBand) {
          final f = (1 - off / _ringBand) * (1 - age / _ringLife);
          // Flick perpendicular to the ring (along its tangent) and brighten.
          target += _wrap(math.atan2(dy, dx) + math.pi / 2 - target) * f;
          tint = math.max(tint, f * _ringFlash);
        }
      }
      final rate = tint > colors[i] ? follow : relax;
      final da = _wrap(target - angles[i]);
      angles[i] += da * rate;
      lengths[i] += (stretch - lengths[i]) * rate;
      colors[i] += (tint - colors[i]) * rate;
      // Dashes trail the slow resting wave by ~0.016 rad; anything beyond
      // _settledAngle is a real transient that needs every frame.
      if (!busy &&
          ((colors[i] - tint).abs() > 1e-3 ||
              (lengths[i] - stretch).abs() > 1e-3 ||
              da.abs() > _settledAngle)) {
        busy = true;
      }
    }
    return busy;
  }

  void _ageRings(double dt) {
    var kept = 0;
    for (var k = 0; k < _ringCount; k++) {
      final age = _rings[k * 3 + 2] + dt;
      if (age >= _ringLife) continue;
      _rings[kept * 3] = _rings[k * 3];
      _rings[kept * 3 + 1] = _rings[k * 3 + 1];
      _rings[kept * 3 + 2] = age;
      kept++;
    }
    _ringCount = kept;
  }

  /// A dash is a line, so angles that differ by pi look the same: the
  /// shortest turn is within (-pi/2, pi/2].
  static double _wrap(double a) => a - math.pi * (a / math.pi).roundToDouble();
}

class _FieldPainter extends CustomPainter {
  _FieldPainter({
    required this.field,
    required Listenable repaint,
    required this.neutral,
    required this.accent,
  }) : _paints = [
         for (var b = 0; b < _colorBuckets; b++)
           Paint()
             ..strokeWidth = _strokeWidth
             ..strokeCap = StrokeCap.round
             ..color = Color.lerp(
               neutral.withValues(alpha: neutral.a * _restOpacity),
               accent.withValues(alpha: _accentOpacity),
               b / (_colorBuckets - 1),
             )!,
       ],
       super(repaint: repaint);

  final _FieldSimulation field;
  final Color neutral;
  final Color accent;
  final List<Paint> _paints;

  @override
  void paint(Canvas canvas, Size size) {
    final f = field;
    final points = f.points;
    final sizes = f.bucketSizes..fillRange(0, _colorBuckets, 0);
    final region = f.count * 4;
    for (var i = 0; i < f.count; i++) {
      final b = (f.colors[i] * (_colorBuckets - 1)).round();
      final half = _dashLength * f.lengths[i] / 2;
      final cx = math.cos(f.angles[i]) * half;
      final cy = math.sin(f.angles[i]) * half;
      final at = b * region + sizes[b] * 4;
      points[at] = f.xs[i] - cx;
      points[at + 1] = f.ys[i] - cy;
      points[at + 2] = f.xs[i] + cx;
      points[at + 3] = f.ys[i] + cy;
      sizes[b]++;
    }
    for (var b = 0; b < _colorBuckets; b++) {
      if (sizes[b] == 0) continue;
      final start = b * region;
      canvas.drawRawPoints(
        ui.PointMode.lines,
        Float32List.sublistView(points, start, start + sizes[b] * 4),
        _paints[b],
      );
    }
  }

  @override
  bool shouldRepaint(_FieldPainter old) =>
      old.field != field || old.neutral != neutral || old.accent != accent;
}
