import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/api/owner_api.dart';
import '../common/format.dart';
import '../driver/driver_providers.dart';
import 'owner_providers.dart';
import 'owner_text.dart';
import 'owner_widgets.dart';
import 'trips/owner_trips_screen.dart';

/// A vehicle's or a driver's trips on a month calendar: booked (unavailable)
/// days are red, tapping a day lists its trips. Days are IST calendar days.
///
/// [TripSchedule.mine] is the signed-in driver's own calendar in the driver
/// app, with [tripTile] for each trip of the chosen day.
class TripSchedule extends ConsumerStatefulWidget {
  const TripSchedule({this.vehicleId, this.driverId, this.now, super.key})
    : assert((vehicleId == null) != (driverId == null)),
      mine = false,
      tripTile = null;

  const TripSchedule.mine({required this.tripTile, this.now, super.key})
    : vehicleId = null,
      driverId = null,
      mine = true;

  /// Exactly one of the two (owner mode).
  final String? vehicleId;
  final String? driverId;

  final bool mine;
  final Widget Function(Trip trip)? tripTile;

  /// Today, for tests; defaults to the clock.
  final DateTime? now;

  @override
  ConsumerState<TripSchedule> createState() => _TripScheduleState();
}

class _TripScheduleState extends ConsumerState<TripSchedule> {
  late final String _today = istToday(widget.now);
  late DateTime _month = _firstOf(DateTime.parse(_today));
  late String _selected = _today;

  static DateTime _firstOf(DateTime d) => DateTime(d.year, d.month);

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Trips overlapping the month, IST bounds.
  TripFilter get _filter => TripFilter(
    vehicleId: widget.vehicleId,
    driverId: widget.driverId,
    from: istDayRange(_iso(_month)).$1,
    to: istDayRange(_iso(DateTime(_month.year, _month.month + 1))).$1,
    overlapping: true,
  );

  TripRange get _range => (from: _filter.from!, to: _filter.to!);

  AsyncValue<List<Trip>> _watch() => widget.mine
      ? ref.watch(myTripsBetweenProvider(_range))
      : ref.watch(ownerTripsProvider(_filter));

  Future<List<Trip>> _refresh() => widget.mine
      ? ref.refresh(myTripsBetweenProvider(_range).future)
      : ref.refresh(ownerTripsProvider(_filter).future);

  void _goTo(DateTime month) => setState(() {
    _month = _firstOf(month);
    final today = DateTime.parse(_today);
    _selected = _month.year == today.year && _month.month == today.month
        ? _today
        : _iso(_month);
  });

  /// Each IST day a trip's window touches, as YYYY-MM-DD.
  static Iterable<String> _days(Trip t) sync* {
    final first = DateTime.parse(istDate(t.scheduledStartAt));
    // The window is half-open: a trip ending at midnight doesn't book the next day.
    final last = DateTime.parse(
      istDate(t.scheduledEndAt.subtract(const Duration(seconds: 1))),
    );
    for (var d = first; !d.isAfter(last); d = d.add(const Duration(days: 1))) {
      yield _iso(d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final trips = _watch();
    return RefreshPage(
      onRefresh: _refresh,
      children: [
        _CalendarWidth(
          child: Row(
            children: [
              IconButton(
                key: const Key('schedule-prev'),
                tooltip: l.previousMonth,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _goTo(DateTime(_month.year, _month.month - 1)),
              ),
              Expanded(
                child: Text(
                  DateFormat.yMMMM(fmt.locale).format(_month),
                  key: const Key('schedule-month'),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                key: const Key('schedule-next'),
                tooltip: l.nextMonth,
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _goTo(DateTime(_month.year, _month.month + 1)),
              ),
              TextButton(
                key: const Key('schedule-today'),
                onPressed: () => _goTo(DateTime.parse(_today)),
                child: Text(l.today),
              ),
            ],
          ),
        ),
        AsyncView(
          value: trips,
          onRetry: _refresh,
          builder: (list) {
            final booked = list.where((t) => t.status != 'cancelled').toList();
            final byDay = <String, List<Trip>>{};
            for (final t in booked) {
              for (final day in _days(t)) {
                (byDay[day] ??= []).add(t);
              }
            }
            final dayTrips = [
              ...?byDay[_selected],
            ]..sort((a, b) => a.scheduledStartAt.compareTo(b.scheduledStartAt));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CalendarWidth(
                  child: _MonthGrid(
                    month: _month,
                    today: _today,
                    selected: _selected,
                    byDay: byDay,
                    onSelect: (day) => setState(() => _selected = day),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  fmt.calendarDate(_selected),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                if (dayTrips.isEmpty)
                  EmptyState(l.noTripsThisDay)
                else
                  for (final t in dayTrips)
                    widget.tripTile?.call(t) ?? OwnerTripTile(t),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.today,
    required this.selected,
    required this.byDay,
    required this.onSelect,
  });

  final DateTime month;
  final String today;
  final String selected;
  final Map<String, List<Trip>> byDay;
  final ValueChanged<String> onSelect;

  static Color _dot(String status) => switch (status) {
    'started' => Colors.orange.shade700,
    'ended' || 'settled' => Colors.green.shade600,
    'assigned' => TaxcyColors.blue600,
    _ => TaxcyColors.muted,
  };

  @override
  Widget build(BuildContext context) {
    final locale = context.fmt.locale;
    final days = DateUtils.getDaysInMonth(month.year, month.month);
    // Weeks start on Monday; DateTime.weekday is 1 (Mon) to 7 (Sun).
    final lead = month.weekday - 1;
    final weekday = DateFormat.E(locale);
    final cells = <Widget>[
      for (var i = 0; i < 7; i++)
        Center(
          child: Text(
            weekday.format(DateTime(2024, 1, 1 + i)),
            style: const TextStyle(fontSize: 12, color: TaxcyColors.muted),
          ),
        ),
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (var d = 1; d <= days; d++)
        _DayCell(
          day: d,
          iso: _TripScheduleState._iso(DateTime(month.year, month.month, d)),
          today: today,
          selected: selected,
          trips:
              byDay[_TripScheduleState._iso(
                DateTime(month.year, month.month, d),
              )] ??
              const [],
          dot: _dot,
          onSelect: onSelect,
        ),
    ];
    return GridView.count(
      key: const Key('schedule-grid'),
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.15,
      children: cells,
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.iso,
    required this.today,
    required this.selected,
    required this.trips,
    required this.dot,
    required this.onSelect,
  });

  final int day;
  final String iso;
  final String today;
  final String selected;
  final List<Trip> trips;
  final Color Function(String status) dot;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final isSelected = iso == selected;
    final isToday = iso == today;
    final busy = trips.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: isSelected
            ? TaxcyColors.blue600
            : busy
            ? Colors.red.shade50
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isToday && !isSelected
              ? const BorderSide(color: TaxcyColors.blue600, width: 1.5)
              : busy && !isSelected
              ? BorderSide(color: Colors.red.shade200)
              : BorderSide.none,
        ),
        child: InkWell(
          key: ValueKey('schedule-day-$iso'),
          borderRadius: BorderRadius.circular(8),
          onTap: () => onSelect(iso),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.fmt.number(day),
                style: TextStyle(
                  fontWeight: busy ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : busy
                      ? Colors.red.shade700
                      : TaxcyColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              SizedBox(
                height: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final t in trips.take(3))
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : dot(t.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Keeps the calendar compact on wide screens, aligned to the left.
class _CalendarWidth extends StatelessWidget {
  const _CalendarWidth({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.topStart,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: child,
    ),
  );
}
