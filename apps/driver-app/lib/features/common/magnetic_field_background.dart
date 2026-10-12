import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Tunables. Lengths in logical px, times in seconds.
const _dotSize = 1.5; // resting dot diameter
const _maxDotSize = 4.0; // dot diameter right at the pointer
const _restOpacity = 0.24; // resting dot opacity
const _accentOpacity = 0.7; // dot opacity at full accent
// The resting wave: a main wave and a slower cross swell, both travelling.
// Each dot rises and falls with them and sways a little sideways, like water.
const _waveHeight = 3.2; // how far a dot rises and falls with the main wave
const _waveLength = 460.0; // distance between its crests
const _wavePeriod = 5.0; // one cycle at a given dot
const _swellHeight = 1.6;
const _swellLength = 290.0;
const _swellPeriod = 8.0;
const _sway = 0.45; // sideways motion, as a share of the rise and fall
const _waveLift = 0.26; // how much a crest brightens and grows dots
const _maxShift = 12.0; // how far dots are pushed out of the pointer's way
const _stiffness = 110.0; // spring pulling a dot back to its place
const _damping = 15.0; // below 2*sqrt(stiffness) (~21) dots wobble a little
const _drag = 7.0; // how strongly a moving pointer drags nearby dots along
const _tintIn = 0.05; // easing towards the accent (~150 ms)
const _tintOut = 0.3; // easing back to neutral (~900 ms)
const _glowRadius = 150.0; // the soft spotlight under the pointer
const _glowOpacity = 0.1; // its strength at the centre
const _ringSpeed = 420.0; // ripple speed, px/s
const _ringLife = 1.5; // ripple lifetime
const _ringBand = 38.0; // width of the band a ripple pushes and lights up
const _ringPush = 10.0; // how far a passing ripple pushes dots outwards
const _ringOpacity = 0.22; // the ripple's faint ring line, when new
const _maxRings = 3; // older ripples are dropped
const _buckets = 8; // size/colour steps; one draw call each
const _idleFrame = Duration(milliseconds: 33); // resting wave updates at 30 fps
const _settled = 0.05; // px (and px/s / 10) below which the field is at rest

/// A quiet, living background of fine dots. At rest they rise and fall with
/// a slow travelling wave, crests catching a little more light; near the pointer they swell, turn to the accent colour and part like
/// a lens under a soft glow, get dragged along when the pointer sweeps past,
/// and spring back with a slight wobble. A tap sends a ripple through them.
/// It sits behind [child] without taking its taps or gestures.
///
/// With reduced motion (MediaQuery.disableAnimations) it draws the resting
/// grid only, with a hover tint but no movement or ripples. Its animation
/// pauses when hidden (TickerMode off) and drops to 30 fps while idle.
class MagneticFieldBackground extends StatefulWidget {
  const MagneticFieldBackground({
    super.key,
    this.child,
    this.accentColor,
    this.spacing = 16,
    this.influenceRadius = 180,
    this.enableRipples = true,
  });

  /// Content rendered above the field.
  final Widget? child;

  /// Colour the dots turn near the pointer (default indigo).
  final Color? accentColor;

  /// Distance between dots.
  final double spacing;

  /// How far from the pointer dots react.
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

  /// While settled, only the slow wave moves: 30 updates a second do.
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
    final from = _field.magnet;
    if (at != null && from != null && _motion) {
      _field.drag(at, at - from, widget.influenceRadius);
    }
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
          _field.layout(size, widget.spacing);
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

/// Per-dot state in flat arrays (no per-dot objects), stepped once a frame:
/// each dot is a damped spring pulled towards a target offset from its place.
class _FieldSimulation {
  int count = 0;
  Float32List xs = Float32List(0); // resting position
  Float32List ys = Float32List(0);
  Float32List ox = Float32List(0); // offset from the resting position
  Float32List oy = Float32List(0);
  Float32List vx = Float32List(0); // velocity of the offset
  Float32List vy = Float32List(0);
  Float32List tints = Float32List(0); // 0 = neutral, 1 = full accent

  /// Dot centres for drawRawPoints, one region of count * 2 per bucket.
  Float32List points = Float32List(0);
  final bucketSizes = Int32List(_buckets);

  /// Ripples as (x, y, age) triples, oldest first.
  final rings = Float32List(_maxRings * 3);
  int ringCount = 0;

  Offset? magnet;

  /// Where the glow is drawn and how strong it is (it fades in and out).
  double glowX = 0;
  double glowY = 0;
  double glow = 0;

  double time = 0;

  /// Off with reduced motion: the wave then stands still.
  bool motion = true;

  void layout(Size size, double spacing) {
    final cols = (size.width / spacing).floor() + 1;
    final rows = (size.height / spacing).floor() + 1;
    final left = (size.width - (cols - 1) * spacing) / 2;
    final top = (size.height - (rows - 1) * spacing) / 2;
    count = cols * rows;
    xs = Float32List(count);
    ys = Float32List(count);
    ox = Float32List(count);
    oy = Float32List(count);
    vx = Float32List(count);
    vy = Float32List(count);
    tints = Float32List(count);
    points = Float32List(count * 2 * _buckets);
    var i = 0;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++, i++) {
        xs[i] = left + c * spacing;
        ys[i] = top + r * spacing;
      }
    }
  }

  void addRing(Offset at) {
    if (ringCount == _maxRings) {
      rings.setRange(0, (_maxRings - 1) * 3, rings, 3); // drop the oldest
      ringCount--;
    }
    final at3 = ringCount * 3;
    rings[at3] = at.dx;
    rings[at3 + 1] = at.dy;
    rings[at3 + 2] = 0;
    ringCount++;
  }

  void clearRings() => ringCount = 0;

  /// A pointer sweeping by [delta] at [at] drags the dots under it along.
  void drag(Offset at, Offset delta, double radius) {
    final r2 = radius * radius;
    for (var i = 0; i < count; i++) {
      final dx = xs[i] - at.dx;
      final dy = ys[i] - at.dy;
      final d2 = dx * dx + dy * dy;
      if (d2 >= r2) continue;
      final t = 1 - math.sqrt(d2) / radius;
      final w = t * t;
      vx[i] += delta.dx * _drag * w;
      vy[i] += delta.dy * _drag * w;
    }
  }

  /// Advances the field by [dt] seconds. Returns whether anything is still
  /// moving (springs, tints or ripples); a pointer resting over settled dots
  /// isn't.
  bool step(double dt, {required double radius, required bool motion}) {
    this.motion = motion;
    if (motion) time += dt;
    _ageRings(dt);
    final tintIn = 1 - math.exp(-dt / _tintIn);
    final tintOut = 1 - math.exp(-dt / _tintOut);
    final m = magnet;
    if (m != null) {
      glowX = m.dx;
      glowY = m.dy;
    }
    final glowTarget = m == null || !motion ? 0.0 : 1.0;
    glow += (glowTarget - glow) * (glowTarget > glow ? tintIn : tintOut);
    final r2 = radius * radius;
    var busy = ringCount > 0 || (glow - glowTarget).abs() > 1e-3;
    for (var i = 0; i < count; i++) {
      final x = xs[i];
      final y = ys[i];
      var tx = 0.0;
      var ty = 0.0;
      var tint = 0.0;
      if (m != null) {
        final dx = x - m.dx;
        final dy = y - m.dy;
        final d2 = dx * dx + dy * dy;
        if (d2 < r2) {
          final d = math.sqrt(d2);
          final t = 1 - d / radius;
          final w = t * t * (3 - 2 * t); // smoothstep falloff
          tint = w;
          if (motion && d > 0.5) {
            // Part like a lens: pushed outwards, most at mid-radius.
            final push = _maxShift * w * (1 - w * 0.5);
            tx += dx / d * push;
            ty += dy / d * push;
          }
        }
      }
      for (var k = 0; k < ringCount; k++) {
        final dx = x - rings[k * 3];
        final dy = y - rings[k * 3 + 1];
        final age = rings[k * 3 + 2];
        final d = math.sqrt(dx * dx + dy * dy);
        final off = (d - age * _ringSpeed).abs();
        if (off < _ringBand) {
          final f = (1 - off / _ringBand) * (1 - age / _ringLife);
          tint = math.max(tint, f);
          if (d > 0.5) {
            tx += dx / d * _ringPush * f;
            ty += dy / d * _ringPush * f;
          }
        }
      }
      if (motion) {
        // Semi-implicit Euler on a damped spring towards the target offset.
        vx[i] += (_stiffness * (tx - ox[i]) - _damping * vx[i]) * dt;
        vy[i] += (_stiffness * (ty - oy[i]) - _damping * vy[i]) * dt;
        ox[i] += vx[i] * dt;
        oy[i] += vy[i] * dt;
      }
      tints[i] += (tint - tints[i]) * (tint > tints[i] ? tintIn : tintOut);
      if (!busy &&
          ((tints[i] - tint).abs() > 1e-3 ||
              (ox[i] - tx).abs() > _settled ||
              (oy[i] - ty).abs() > _settled ||
              vx[i].abs() > _settled * 10 ||
              vy[i].abs() > _settled * 10)) {
        busy = true;
      }
    }
    return busy;
  }

  void _ageRings(double dt) {
    var kept = 0;
    for (var k = 0; k < ringCount; k++) {
      final age = rings[k * 3 + 2] + dt;
      if (age >= _ringLife) continue;
      rings[kept * 3] = rings[k * 3];
      rings[kept * 3 + 1] = rings[k * 3 + 1];
      rings[kept * 3 + 2] = age;
      kept++;
    }
    ringCount = kept;
  }
}

class _FieldPainter extends CustomPainter {
  _FieldPainter({
    required this.field,
    required Listenable repaint,
    required this.neutral,
    required this.accent,
  }) : _dots = [
         for (var b = 0; b < _buckets; b++)
           Paint()
             ..strokeCap = StrokeCap.round
             ..strokeWidth =
                 _dotSize + (_maxDotSize - _dotSize) * b / (_buckets - 1)
             ..color = Color.lerp(
               neutral.withValues(alpha: neutral.a * _restOpacity),
               accent.withValues(alpha: _accentOpacity),
               b / (_buckets - 1),
             )!,
       ],
       // The glow's gradient is drawn around the origin and moved with a
       // translate, so no shader is built per frame; its strength picks one
       // of a few ready-made paints.
       _glows = [
         for (var g = 1; g <= 4; g++)
           Paint()
             ..shader = ui.Gradient.radial(Offset.zero, _glowRadius, [
               accent.withValues(alpha: _glowOpacity * g / 4),
               accent.withValues(alpha: 0),
             ]),
       ],
       _rings = [
         for (var r = 1; r <= 4; r++)
           Paint()
             ..style = PaintingStyle.stroke
             ..strokeWidth = 1.5
             ..color = accent.withValues(alpha: _ringOpacity * r / 4),
       ],
       super(repaint: repaint);

  final _FieldSimulation field;
  final Color neutral;
  final Color accent;
  final List<Paint> _dots;
  final List<Paint> _glows;
  final List<Paint> _rings;

  @override
  void paint(Canvas canvas, Size size) {
    final f = field;
    final g = (f.glow * _glows.length).round();
    if (g > 0) {
      canvas
        ..save()
        ..translate(f.glowX, f.glowY)
        ..drawCircle(Offset.zero, _glowRadius, _glows[g - 1])
        ..restore();
    }
    for (var k = 0; k < f.ringCount; k++) {
      final age = f.rings[k * 3 + 2];
      final fade = ((1 - age / _ringLife) * _rings.length).ceil();
      if (fade <= 0) continue;
      canvas.drawCircle(
        Offset(f.rings[k * 3], f.rings[k * 3 + 1]),
        age * _ringSpeed,
        _rings[fade - 1],
      );
    }
    final points = f.points;
    final sizes = f.bucketSizes..fillRange(0, _buckets, 0);
    final region = f.count * 2;
    // The main wave runs down and to the right, the swell across it.
    const k1 = 2 * math.pi / _waveLength;
    const k2 = 2 * math.pi / _swellLength;
    final t1 = 2 * math.pi * f.time / _wavePeriod;
    final t2 = 2 * math.pi * f.time / _swellPeriod;
    final move = f.motion ? 1.0 : 0.0;
    for (var i = 0; i < f.count; i++) {
      final x = f.xs[i];
      final y = f.ys[i];
      final p1 = (x * 0.8 + y * 0.6) * k1 - t1;
      final p2 = (y * 0.87 - x * 0.5) * k2 - t2;
      final s1 = math.sin(p1);
      final s2 = math.sin(p2);
      final rise = (s1 * _waveHeight + s2 * _swellHeight) * move;
      final sway = math.cos(p1) * _waveHeight * _sway * move;
      // Crests (0..1) catch the light; the pointer or a ripple lifts more.
      final crest =
          (s1 * _waveHeight + s2 * _swellHeight) /
              (_waveHeight + _swellHeight) *
              0.5 +
          0.5;
      final t = math.max(f.tints[i], crest * crest * _waveLift);
      final b = (t * (_buckets - 1)).round();
      final at = b * region + sizes[b] * 2;
      points[at] = x + f.ox[i] + sway * 0.8;
      points[at + 1] = y + f.oy[i] - rise + sway * 0.6;
      sizes[b]++;
    }
    for (var b = 0; b < _buckets; b++) {
      if (sizes[b] == 0) continue;
      final start = b * region;
      canvas.drawRawPoints(
        ui.PointMode.points,
        Float32List.sublistView(points, start, start + sizes[b] * 2),
        _dots[b],
      );
    }
  }

  @override
  bool shouldRepaint(_FieldPainter old) =>
      old.field != field || old.neutral != neutral || old.accent != accent;
}
