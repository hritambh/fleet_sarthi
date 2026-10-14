import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/api/models.dart';

/// A stretch of an IST day as fractions of it (0 = 00:00, 1 = 24:00).
typedef DaySpan = ({double from, double to});

/// One cab's IST day: the stretches it is held by trips, sorted and merged.
class CabDay {
  const CabDay({
    required this.vehicleId,
    required this.registrationNo,
    required this.active,
    required this.busy,
  });

  final String vehicleId;
  final String registrationNo;
  final bool active;
  final List<DaySpan> busy;

  /// Share of the day (0..1) the cab is held.
  double get busyShare => busy.fold(0, (sum, s) => sum + s.to - s.from);
}

/// When [trip] holds its cab: the scheduled window until it starts, then the
/// actual start to the actual end (a running trip until the later of its
/// scheduled end and [now]). Null when it holds no cab: unassigned, cancelled,
/// or without a vehicle.
(DateTime, DateTime)? occupiedWindow(Trip trip, DateTime now) {
  if (trip.vehicle == null) return null;
  return switch (trip.status) {
    'assigned' => (trip.scheduledStartAt, trip.scheduledEndAt),
    'started' => (
      trip.startedAt ?? trip.scheduledStartAt,
      now.isAfter(trip.scheduledEndAt) ? now : trip.scheduledEndAt,
    ),
    'ended' || 'settled' => (
      trip.startedAt ?? trip.scheduledStartAt,
      trip.endedAt ?? trip.scheduledEndAt,
    ),
    _ => null,
  };
}

/// Every cab's day from [dayStart] (the IST midnight, as an instant) for 24
/// hours: active cabs first, then by registration number.
List<CabDay> cabDays({
  required List<Vehicle> vehicles,
  required List<Trip> trips,
  required DateTime dayStart,
  required DateTime now,
}) {
  const day = Duration(days: 1);
  final dayMs = day.inMilliseconds;
  double at(DateTime t) =>
      (t.difference(dayStart).inMilliseconds / dayMs).clamp(0.0, 1.0);

  final spans = <String, List<DaySpan>>{};
  for (final trip in trips) {
    final window = occupiedWindow(trip, now);
    if (window == null) continue;
    final (from, to) = (at(window.$1), at(window.$2));
    if (to <= from) continue;
    (spans[trip.vehicle!.id] ??= []).add((from: from, to: to));
  }

  final days = [
    for (final v in vehicles)
      CabDay(
        vehicleId: v.id,
        registrationNo: v.registrationNo,
        active: v.isActive,
        busy: _merge(spans[v.id] ?? const []),
      ),
  ];
  return days..sort((a, b) {
    if (a.active != b.active) return a.active ? -1 : 1;
    return a.registrationNo.compareTo(b.registrationNo);
  });
}

/// Share of the active cabs' combined day that is free (0..1); null with no
/// active cab.
double? freeShare(List<CabDay> days) {
  final active = days.where((d) => d.active).toList();
  if (active.isEmpty) return null;
  final busy = active.fold<double>(0, (sum, d) => sum + d.busyShare);
  return 1 - busy / active.length;
}

List<DaySpan> _merge(List<DaySpan> spans) {
  if (spans.isEmpty) return const [];
  final sorted = [...spans]..sort((a, b) => a.from.compareTo(b.from));
  final merged = <DaySpan>[sorted.first];
  for (final s in sorted.skip(1)) {
    final last = merged.last;
    if (s.from <= last.to) {
      merged[merged.length - 1] = (
        from: last.from,
        to: math.max(last.to, s.to),
      );
    } else {
      merged.add(s);
    }
  }
  return merged;
}

const cabFreeColor = Color(0xFF16A34A);
const cabBusyColor = Color(0xFFDC2626);

/// A cab's day as a thin bar: green where it is free, red where a trip holds
/// it, grey if the cab is inactive; faint gaps every six hours and a dark
/// tick at [nowAt] (today only).
class CabDayBar extends StatelessWidget {
  const CabDayBar({required this.day, this.nowAt, super.key});

  final CabDay day;

  /// Now as a fraction of the day; null when the day isn't today.
  final double? nowAt;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size(double.infinity, 10),
    painter: _CabDayPainter(day, nowAt),
  );
}

class _CabDayPainter extends CustomPainter {
  _CabDayPainter(this.day, this.nowAt);

  final CabDay day;
  final double? nowAt;

  @override
  void paint(Canvas canvas, Size size) {
    const barHeight = 5.0;
    final top = (size.height - barHeight) / 2;
    final bar = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, top, size.width, barHeight),
      const Radius.circular(barHeight / 2),
    );
    canvas
      ..save()
      ..clipRRect(bar)
      ..drawRect(
        bar.outerRect,
        Paint()..color = day.active ? cabFreeColor : TaxcyColors.border,
      );
    if (day.active) {
      final busy = Paint()..color = cabBusyColor;
      for (final s in day.busy) {
        // At least a pixel, so a short trip still shows.
        final width = math.max((s.to - s.from) * size.width, 1.5);
        canvas.drawRect(
          Rect.fromLTWH(s.from * size.width, top, width, barHeight),
          busy,
        );
      }
    }
    // Faint gaps at 06:00, 12:00 and 18:00, for a sense of the hours.
    final tick = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (final q in const [0.25, 0.5, 0.75]) {
      canvas.drawRect(
        Rect.fromLTWH(q * size.width - 0.5, top, 1, barHeight),
        tick,
      );
    }
    canvas.restore();
    if (nowAt case final now?) {
      final x = now * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = TaxcyColors.ink
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_CabDayPainter old) =>
      old.day != day || old.nowAt != nowAt;
}

/// A small ring: green for the free share, red for the rest.
class FreeShareRing extends StatelessWidget {
  const FreeShareRing({required this.free, this.size = 22, super.key});

  /// 0..1.
  final double free;
  final double size;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _RingPainter(free.clamp(0, 1)),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.free);

  final double free;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 4.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    Paint arc(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    const start = -math.pi / 2;
    final sweep = free * 2 * math.pi;
    canvas
      ..drawArc(rect, start, 2 * math.pi, false, arc(cabBusyColor))
      ..drawArc(rect, start, sweep, false, arc(cabFreeColor));
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.free != free;
}
