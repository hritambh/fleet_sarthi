import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Tunables. Lengths in logical px, times in seconds.
const _dotSize = 1.9; // resting dot diameter
const _maxDotSize = 4.4; // dot diameter right at the pointer
const _restOpacity = 0.45; // resting dot opacity
const _accentOpacity = 0.8; // dot opacity at full accent
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
// A tap sends a ripple through the dots, like a stone dropped in water: a
// short train of crests that travels outwards. It moves and lights the dots
// directly (not through their springs), so it keeps its shape; no line is
// drawn, the dots alone show it.
const _ringSpeed = 420.0; // ripple speed, px/s
const _ringLife = 2.8; // ripple lifetime (it reaches ~1200 px)
const _ringWavelength = 46.0; // distance between its crests
const _ringSpread = 70.0; // how far the crest train reaches either side
const _ringPush = 5.0; // how far its crests move dots, when new
const _ringLight = 0.9; // how much its crests light dots, when new
// Without any input, a softer wave starts off-screen to the left every
// second and sweeps across the whole field as a gently curved front.
const _autoEvery = 1.0; // seconds between waves
const _autoStrength = 0.7; // compared with a tap's ripple
const _autoOffset = 320.0; // how far left of the field they start
const _maxRings = 10; // older ripples are dropped
const _ringFields = 5; // per ripple: x, y, age, life, strength
const _buckets = 8; // size/colour steps; one draw call each
const _idleFrame = Duration(milliseconds: 33); // resting wave updates at 30 fps
const _settled = 0.05; // px (and px/s / 10) below which the field is at rest

/// A quiet, living background of fine dots. At rest they rise and fall with
/// a slow travelling wave, crests catching a little more light, and every
/// second a softer wave sweeps across them; near the pointer they swell, turn to the accent colour and part like
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

  /// Ripples, oldest first, [_ringFields] floats each. Taps have strength 1;
  /// the automatic waves less.
  final rings = Float32List(_maxRings * _ringFields);
  int ringCount = 0;

  Size size = Size.zero;
  final _random = math.Random();
  double _untilAuto = 0;

  Offset? magnet;

  /// Where the glow is drawn and how strong it is (it fades in and out).
  double glowX = 0;
  double glowY = 0;
  double glow = 0;

  double time = 0;

  /// Off with reduced motion: the wave then stands still.
  bool motion = true;

  void layout(Size size, double spacing) {
    this.size = size;
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

  /// A tap's ripple.
  void addRing(Offset at) => _addRing(at, _ringLife, 1);

  /// An automatic wave from off-screen left, living until it has crossed the
  /// field.
  void _addAutoWave() {
    final from = Offset(-_autoOffset, size.height * _random.nextDouble());
    final far = math.max(
      (Offset(size.width, 0) - from).distance,
      (Offset(size.width, size.height) - from).distance,
    );
    _addRing(from, (far + _ringSpread * 2) / _ringSpeed, _autoStrength);
  }

  void _addRing(Offset at, double life, double strength) {
    const n = _ringFields;
    if (ringCount == _maxRings) {
      rings.setRange(0, (_maxRings - 1) * n, rings, n); // drop the oldest
      ringCount--;
    }
    final at0 = ringCount * n;
    rings[at0] = at.dx;
    rings[at0 + 1] = at.dy;
    rings[at0 + 2] = 0;
    rings[at0 + 3] = life;
    rings[at0 + 4] = strength;
    ringCount++;
  }

  /// Whether a tap's ripple is still running (the automatic waves alone
  /// don't need a frame every vsync; the 30 fps idle updates carry them).
  bool get _tapRippling {
    for (var k = 0; k < ringCount; k++) {
      if (rings[k * _ringFields + 4] >= 1) return true;
    }
    return false;
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
    if (motion && !size.isEmpty) {
      _untilAuto -= dt;
      if (_untilAuto <= 0) {
        _addAutoWave();
        _untilAuto = _autoEvery;
      }
    }
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
    var busy = _tapRippling || (glow - glowTarget).abs() > 1e-3;
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
    const n = _ringFields;
    for (var k = 0; k < ringCount; k++) {
      final age = rings[k * n + 2] + dt;
      if (age >= rings[k * n + 3]) continue;
      if (kept != k) rings.setRange(kept * n, kept * n + n, rings, k * n);
      rings[kept * n + 2] = age;
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
       super(repaint: repaint);

  final _FieldSimulation field;
  final Color neutral;
  final Color accent;
  final List<Paint> _dots;
  final List<Paint> _glows;

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
    // Each ripple's centre, front radius and strength (fading out smoothly).
    final ringCount = f.ringCount;
    final ringX = Float32List(ringCount);
    final ringY = Float32List(ringCount);
    final ringFront = Float32List(ringCount);
    final ringFade = Float32List(ringCount);
    const n = _ringFields;
    for (var k = 0; k < ringCount; k++) {
      final age = f.rings[k * n + 2];
      final left = 1 - age / f.rings[k * n + 3];
      final strength = f.rings[k * n + 4];
      ringX[k] = f.rings[k * n];
      ringY[k] = f.rings[k * n + 1];
      ringFront[k] = age * _ringSpeed;
      // A tap's ripple fades as it spreads; an automatic wave stays even
      // until it nears the far edge.
      ringFade[k] = strength >= 1
          ? left * left
          : strength * math.min(1, left * 4);
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
      var t = math.max(f.tints[i], crest * crest * _waveLift);
      var px = x + f.ox[i] + sway * 0.8;
      var py = y + f.oy[i] - rise + sway * 0.6;
      for (var k = 0; k < ringCount; k++) {
        final dx = x - ringX[k];
        final dy = y - ringY[k];
        final d = math.sqrt(dx * dx + dy * dy);
        // Distance from the middle of the crest train.
        final off = d - ringFront[k];
        if (off.abs() > _ringSpread * 2.2 || d < 0.5) continue;
        final u = off / _ringSpread;
        final env = math.exp(-u * u) * ringFade[k];
        final phase = 2 * math.pi * off / _ringWavelength;
        // Dots bob outwards and back as each crest passes, and light up on
        // the crests.
        final push = math.sin(phase) * _ringPush * env;
        px += dx / d * push;
        py += dy / d * push;
        final crest = 0.5 + 0.5 * math.cos(phase);
        t = math.max(t, crest * crest * _ringLight * env);
      }
      final b = (t * (_buckets - 1)).round();
      final at = b * region + sizes[b] * 2;
      points[at] = px;
      points[at + 1] = py;
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
