import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

// Tunables. Lengths in logical px (or shares of the field's width W and
// height H), times in seconds.

// The sheet: rows of dots forming a water surface seen in perspective. Its top
// edge rises diagonally from the left (_edgeLeft·H down) to the right
// (_edgeRight·H down), so it covers about 70% of the field; far rows (at the
// edge) are tight and small, near rows (at the bottom) wide and bigger.
const _edgeLeft = 0.62;
const _edgeRight = 0.02;
const _edgeRipple = 0.06; // how much the top edge undulates (share of H)
const _edgePeriod = 9.0; // one undulation cycle
const _depthCurve = 1.45; // >1 packs the far rows together
const _rowsPerSpacing = 1.3; // rows per `spacing` of field height
const _farGap = 0.45; // gap between dots in the far row, in `spacing`s
const _nearGap = 1.1; // and in the nearest row
const _swellHeight = 0.03; // the surface's own swell (share of H)
const _swellLength = 0.5; // its wavelength (share of W)
const _swellPeriod = 6.0;
const _sheen = 0.12; // how much a raised swell lightens dots

// Dot looks. A dot's level (0..1) sets its size and opacity: depth gives the
// base, the pointer and waves lift it.
const _minDot = 0.9; // diameter at level 0
const _maxDot = 4.0; // at level 1
const _minAlpha = 0.22;
const _maxAlpha = 0.85;
const _levels = 8; // size/opacity steps
// Hues across the sheet, left to right (one draw call per hue and level).
const _hues = [
  Color(0xFF2563EB), // blue
  Color(0xFF0EA5E9), // sky
  Color(0xFF8B5CF6), // violet
  Color(0xFFEC4899), // pink
];

// The pointer.
const _maxShift = 12.0; // how far dots are pushed out of the pointer's way
const _stiffness = 110.0; // spring pulling a dot back to its place
const _damping = 15.0; // below 2*sqrt(stiffness) (~21) dots wobble a little
const _drag = 7.0; // how strongly a moving pointer drags nearby dots along
const _tintIn = 0.05; // easing towards highlighted (~150 ms)
const _tintOut = 0.3; // easing back (~900 ms)
const _glowRadius = 150.0; // the soft spotlight under the pointer
const _glowOpacity = 0.1; // its strength at the centre

// A tap sends a ripple through the dots, like a stone dropped in water: a
// short train of crests that travels outwards. It moves and lights the dots
// directly (not through their springs), so it keeps its shape.
const _ringSpeed = 420.0; // ripple speed, px/s
const _ringLife = 2.8; // ripple lifetime (it reaches ~1200 px)
const _ringWavelength = 46.0; // distance between its crests
const _ringSpread = 70.0; // how far the crest train reaches either side
const _ringPush = 5.0; // how far its crests move dots, when new
const _ringLight = 0.9; // how much its crests light dots, when new

// Without input, a broad swell rolls along the sheet's diagonal, lifting and
// lighting the dots it passes. Only one runs at a time: the next starts a
// moment after it (and any tap ripple) has finished. A tap fades it out.
const _swellSpeed = 520.0; // px/s
const _swellWidth = 140.0; // half-width of the swell band
const _swellLift = 9.0; // how far it raises dots
const _swellLight = 0.5; // how much it lights them
const _swellGap = 0.8; // pause between swells
const _swellCancel = 0.3; // fade-out when a tap interrupts it

const _idleFrame = Duration(milliseconds: 33); // idle updates at 30 fps
const _settled = 0.05; // px (and px/s / 10) below which the field is at rest

/// A living background: a sheet of fine dots like a water surface, rising
/// diagonally across the field and gently swelling, with a broad wave
/// rolling along it now and then. Near the pointer the dots swell, brighten
/// and part like a lens under a soft glow, get dragged along when the
/// pointer sweeps past, and spring back with a slight wobble. A tap sends a
/// ripple through them. It sits behind [child] without taking its taps or
/// gestures.
///
/// With reduced motion (MediaQuery.disableAnimations) the sheet stands still,
/// with a hover highlight but no movement, waves or ripples. Its animation
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

  /// Colour of the glow under the pointer (default indigo).
  final Color? accentColor;

  /// Typical distance between dots (near rows are a little wider apart, far
  /// rows tighter).
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
  // Two clocks: the ticker (every frame) while the pointer or a tap ripple is
  // moving things, and a slower timer for the sheet's own motion. An idle
  // field never asks for a frame per vsync, which on the web would cost a
  // full composite each time.
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
    if (!_motion) _field.stopWaves();
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

  /// While settled, only the sheet and its swell move: 30 updates a second.
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
      _field.tap(e.localPosition);
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

/// Per-dot state in flat arrays (no per-dot objects). Each step places every
/// dot on the moving sheet, then runs a damped spring per dot towards the
/// pointer's push, as an offset from that place.
class _FieldSimulation {
  Size size = Size.zero;
  int count = 0;
  Float32List xs = Float32List(0); // where on the sheet: x on screen
  Float32List rows = Float32List(0); // and row, 0 (far edge) .. 1 (near)
  Float32List depths = Float32List(0); // row eased by _depthCurve
  Float32List bx = Float32List(0); // this step's place on the sheet
  Float32List by = Float32List(0);
  Float32List levels = Float32List(0); // this step's level before the pointer
  Float32List ox = Float32List(0); // spring offset from that place
  Float32List oy = Float32List(0);
  Float32List vx = Float32List(0); // velocity of the offset
  Float32List vy = Float32List(0);
  Float32List tints = Float32List(0); // pointer highlight, 0..1

  Offset? magnet;

  /// Where the glow is drawn and how strong it is (it fades in and out).
  double glowX = 0;
  double glowY = 0;
  double glow = 0;

  double time = 0;

  /// Off with reduced motion: the sheet then stands still.
  bool motion = true;

  // The tap ripple (one at a time).
  bool rippling = false;
  double rippleX = 0;
  double rippleY = 0;
  double rippleAge = 0;

  // The rolling swell (one at a time).
  bool swelling = false;
  double swellAge = 0;
  double swellLife = 0;
  double swellFade = 1; // drops to 0 when a tap cancels it
  bool swellCancelled = false;
  double untilSwell = _swellGap;

  void layout(Size size, double spacing) {
    this.size = size;
    final w = size.width;
    final rowCount = (size.height / spacing * _rowsPerSpacing).round().clamp(
      12,
      72,
    );
    final x = <double>[];
    final row = <double>[];
    for (var r = 0; r < rowCount; r++) {
      final t = r / (rowCount - 1);
      final gap = spacing * (_farGap + (_nearGap - _farGap) * t);
      // Staggered rows, overscanning the sides so the swell can sway them in.
      for (
        var at = -0.1 * w + (r.isOdd ? gap / 2 : 0);
        at < 1.1 * w;
        at += gap
      ) {
        x.add(at);
        row.add(t);
      }
    }
    count = x.length;
    xs = Float32List.fromList(x);
    rows = Float32List.fromList(row);
    depths = Float32List(count);
    for (var i = 0; i < count; i++) {
      depths[i] = math.pow(rows[i], _depthCurve).toDouble();
    }
    bx = Float32List(count);
    by = Float32List(count);
    levels = Float32List(count);
    ox = Float32List(count);
    oy = Float32List(count);
    vx = Float32List(count);
    vy = Float32List(count);
    tints = Float32List(count);
    _placeSheet();
  }

  /// A tap: starts a ripple unless one is still running, and fades out a
  /// rolling swell so the two don't pile up.
  void tap(Offset at) {
    if (rippling) return;
    rippling = true;
    rippleX = at.dx;
    rippleY = at.dy;
    rippleAge = 0;
    if (swelling) swellCancelled = true;
  }

  void stopWaves() {
    rippling = false;
    swelling = false;
  }

  /// A pointer sweeping by [delta] at [at] drags the dots under it along.
  void drag(Offset at, Offset delta, double radius) {
    final r2 = radius * radius;
    for (var i = 0; i < count; i++) {
      final dx = bx[i] - at.dx;
      final dy = by[i] - at.dy;
      final d2 = dx * dx + dy * dy;
      if (d2 >= r2) continue;
      final t = 1 - math.sqrt(d2) / radius;
      final w = t * t;
      vx[i] += delta.dx * _drag * w;
      vy[i] += delta.dy * _drag * w;
    }
  }

  /// Advances the field by [dt] seconds. Returns whether the pointer's springs
  /// or a tap ripple still need a frame every vsync; the sheet and its swell
  /// alone don't (the 30 fps idle updates carry them).
  bool step(double dt, {required double radius, required bool motion}) {
    this.motion = motion;
    if (motion) {
      time += dt;
      _advanceWaves(dt);
    }
    _placeSheet();
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
    var busy = rippling || (glow - glowTarget).abs() > 1e-3;
    for (var i = 0; i < count; i++) {
      var tx = 0.0;
      var ty = 0.0;
      var tint = 0.0;
      if (m != null) {
        final dx = bx[i] - m.dx;
        final dy = by[i] - m.dy;
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

  void _advanceWaves(double dt) {
    if (rippling) {
      rippleAge += dt;
      if (rippleAge >= _ringLife) rippling = false;
    }
    if (swelling) {
      swellAge += dt;
      if (swellCancelled) swellFade -= dt / _swellCancel;
      if (swellAge >= swellLife || swellFade <= 0) {
        swelling = false;
        untilSwell = _swellGap;
      }
    } else if (!rippling && !size.isEmpty) {
      // The next swell waits until nothing else is running.
      untilSwell -= dt;
      if (untilSwell <= 0) {
        final (lo, hi) = _swellRange();
        swelling = true;
        swellCancelled = false;
        swellFade = 1;
        swellAge = 0;
        swellLife = (hi - lo + 4 * _swellWidth) / _swellSpeed;
      }
    }
  }

  /// The swell runs along the sheet's rising diagonal.
  (double, double) get _swellDirection {
    final dx = size.width;
    final dy = -(_edgeLeft - _edgeRight) * size.height;
    final len = math.sqrt(dx * dx + dy * dy);
    return (dx / len, dy / len);
  }

  /// The swell's position range over the field, along its direction.
  (double, double) _swellRange() {
    final (ux, uy) = _swellDirection;
    final w = size.width;
    final h = size.height;
    final corners = [0.0, w * ux, h * uy, w * ux + h * uy];
    return (corners.reduce(math.min), corners.reduce(math.max));
  }

  /// Puts every dot on the sheet as it is at [time], with its base level.
  void _placeSheet() {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;
    final edgePhase = 2 * math.pi * time / _edgePeriod;
    final swellPhase = 2 * math.pi * time / _swellPeriod;
    final edgeK = 2 * math.pi / (1.1 * w);
    final swellK = 2 * math.pi / (_swellLength * w);
    final bottom = h * 1.04;
    final (ux, uy) = _swellDirection;
    var front = 0.0;
    var swell = 0.0;
    if (swelling) {
      final (lo, _) = _swellRange();
      front = lo - 2 * _swellWidth + swellAge * _swellSpeed;
      // Eases in and out so it never pops.
      final p = swellAge / swellLife;
      swell = math.min(1, math.min(p, 1 - p) * 6) * swellFade.clamp(0, 1);
    }
    for (var i = 0; i < count; i++) {
      final x = xs[i];
      final t = rows[i];
      final edge =
          h * (_edgeLeft - (_edgeLeft - _edgeRight) * x / w) +
          h * _edgeRipple * math.sin(x * edgeK - edgePhase);
      final base = edge + (bottom - edge) * depths[i];
      final phase = (x * 0.78 - base * 0.62) * swellK - swellPhase + t * 2.2;
      final s = math.sin(phase);
      final amp = h * _swellHeight * (1 - 0.5 * t);
      var y = base + amp * s;
      final px = x + amp * 0.35 * math.cos(phase);
      // Far rows fade in from nothing at the edge; near rows are bigger.
      var level =
          (0.24 + 0.36 * t) * math.min(1, t / 0.05) + _sheen * math.max(0, -s);
      if (swell > 0) {
        final u = (px * ux + y * uy - front) / _swellWidth;
        if (u > -3 && u < 3) {
          final g = math.exp(-u * u) * swell;
          y -= _swellLift * g;
          level += _swellLight * g;
        }
      }
      bx[i] = px;
      by[i] = y;
      levels[i] = level;
    }
  }
}

class _FieldPainter extends CustomPainter {
  _FieldPainter({
    required this.field,
    required Listenable repaint,
    required this.accent,
  }) : _dots = [
         for (final hue in _hues)
           for (var l = 0; l < _levels; l++)
             Paint()
               ..strokeCap = StrokeCap.round
               ..strokeWidth = _minDot + (_maxDot - _minDot) * l / (_levels - 1)
               ..color = hue.withValues(
                 alpha: _minAlpha + (_maxAlpha - _minAlpha) * l / (_levels - 1),
               ),
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
  final Color accent;
  final List<Paint> _dots;
  final List<Paint> _glows;

  // Reused between frames: each dot's bucket, then the points grouped by it.
  Uint8List _bucketOf = Uint8List(0);
  Float32List _xs = Float32List(0);
  Float32List _ys = Float32List(0);
  Float32List _points = Float32List(0);
  final _bucketSizes = Int32List(_hues.length * _levels);
  final _bucketStarts = Int32List(_hues.length * _levels);

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
    if (f.count == 0 || size.isEmpty) return;
    if (_bucketOf.length != f.count) {
      _bucketOf = Uint8List(f.count);
      _xs = Float32List(f.count);
      _ys = Float32List(f.count);
      _points = Float32List(f.count * 2);
    }
    final ripple = f.rippling;
    final left = 1 - f.rippleAge / _ringLife;
    final rippleFade = left * left;
    final rippleFront = f.rippleAge * _ringSpeed;
    final huesSpan = (_hues.length - 1) / size.width;
    final sizes = _bucketSizes..fillRange(0, _bucketSizes.length, 0);
    final xs = _xs;
    final ys = _ys;
    for (var i = 0; i < f.count; i++) {
      var px = f.bx[i] + f.ox[i];
      var py = f.by[i] + f.oy[i];
      final tint = f.tints[i];
      var level = f.levels[i] + tint * (1 - f.levels[i]) * 0.9;
      if (ripple) {
        final dx = f.bx[i] - f.rippleX;
        final dy = f.by[i] - f.rippleY;
        final d = math.sqrt(dx * dx + dy * dy);
        final off = d - rippleFront;
        if (off.abs() < _ringSpread * 2.2 && d > 0.5) {
          final u = off / _ringSpread;
          final env = math.exp(-u * u) * rippleFade;
          final phase = 2 * math.pi * off / _ringWavelength;
          // Dots bob outwards and back as each crest passes, and light up on
          // the crests.
          final push = math.sin(phase) * _ringPush * env;
          px += dx / d * push;
          py += dy / d * push;
          final crest = 0.5 + 0.5 * math.cos(phase);
          level += crest * crest * _ringLight * env;
        }
      }
      if (py < -4 || py > size.height + 4 || px < -4 || px > size.width + 4) {
        _bucketOf[i] = 255; // off-screen
        continue;
      }
      final hue = (px * huesSpan).round().clamp(0, _hues.length - 1);
      final l = (level.clamp(0.0, 1.0) * (_levels - 1)).round();
      final b = hue * _levels + l;
      _bucketOf[i] = b;
      sizes[b]++;
      xs[i] = px;
      ys[i] = py;
    }
    var start = 0;
    for (var b = 0; b < sizes.length; b++) {
      _bucketStarts[b] = start;
      start += sizes[b];
    }
    final fill = Int32List.fromList(_bucketStarts);
    for (var i = 0; i < f.count; i++) {
      final b = _bucketOf[i];
      if (b == 255) continue;
      final at = fill[b]++ * 2;
      _points[at] = xs[i];
      _points[at + 1] = ys[i];
    }
    for (var b = 0; b < sizes.length; b++) {
      if (sizes[b] == 0) continue;
      final from = _bucketStarts[b] * 2;
      canvas.drawRawPoints(
        ui.PointMode.points,
        Float32List.sublistView(_points, from, from + sizes[b] * 2),
        _dots[b],
      );
    }
  }

  @override
  bool shouldRepaint(_FieldPainter old) =>
      old.field != field || old.accent != accent;
}
