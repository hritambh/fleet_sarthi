import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/api/models.dart';
import '../../../core/api/owner_api.dart';
import '../../../core/api/owner_models.dart';
import '../../common/format.dart';
import '../owner_providers.dart';
import '../owner_text.dart';
import '../alerts_inbox.dart';
import '../owner_widgets.dart';
import 'create_trip_screen.dart';
import 'owner_trip_detail_screen.dart';
import '../../common/theme_picker.dart';

const tripStatuses = [
  'created',
  'assigned',
  'started',
  'ended',
  'settled',
  'cancelled',
];

/// Every trip in the fleet, filtered by status, IST day, driver and vehicle.
class OwnerTripsScreen extends ConsumerStatefulWidget {
  const OwnerTripsScreen({this.initialStatus, super.key});

  /// Starts filtered to this status (the dashboard's "resolve queue").
  final String? initialStatus;

  @override
  ConsumerState<OwnerTripsScreen> createState() => _OwnerTripsScreenState();
}

class _OwnerTripsScreenState extends ConsumerState<OwnerTripsScreen> {
  late var _statuses = {?widget.initialStatus};
  var _driverIds = <String>{};
  var _vehicleIds = <String>{};

  /// First and last IST day (YYYY-MM-DD), both included.
  (String, String)? _days;

  TripFilter get _filter => TripFilter(
    statuses: _statuses,
    driverIds: _driverIds,
    vehicleIds: _vehicleIds,
    from: _days == null ? null : istDayRange(_days!.$1).$1,
    to: _days == null ? null : istDayRange(_days!.$2).$2,
  );

  bool get _filtered =>
      _statuses.isNotEmpty ||
      _driverIds.isNotEmpty ||
      _vehicleIds.isNotEmpty ||
      _days != null;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final trips = ref.watch(ownerTripsProvider(_filter));
    final desktop = isDesktop(context);
    final action = PageAction(
      key: const Key('owner-new-trip'),
      icon: Icons.add,
      label: l.newTrip,
      onPressed: () => openScreen<void>(context, const CreateTripScreen()),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(l.navTrips),
        actions: [
          if (!desktop)
            IconButton(
              key: const Key('trip-filters'),
              tooltip: l.filters,
              // A dot while any filter is on: the list isn't showing everything.
              icon: Badge(
                isLabelVisible: _filtered,
                child: const Icon(Icons.tune),
              ),
              onPressed: _showFilters,
            ),
          const ThemeToggleButton(),
          const AlertsBell(),
          ...action.headerActions(context),
        ],
      ),
      floatingActionButton: action.fab(context),
      body: RefreshPage(
        onRefresh: () => ref.refresh(ownerTripsProvider(_filter).future),
        children: [
          if (desktop) _filterRow(context),
          AsyncView(
            value: trips,
            onRetry: () => ref.invalidate(ownerTripsProvider(_filter)),
            builder: (list) => list.isEmpty
                ? EmptyState(l.noTripsMatch)
                : desktop
                ? TripTable(list)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final (day, group) in groupTripsByDay(list)) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 2),
                          child: Text(
                            tripDayLabel(context, day),
                            key: ValueKey('trip-day-$day'),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        for (final t in group) OwnerTripTile(t),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() {
    _statuses = {};
    _driverIds = {};
    _vehicleIds = {};
    _days = null;
  }

  /// The desktop's filters: one row above the table.
  Widget _filterRow(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final field in _filterFields(context, ref, setState))
            SizedBox(width: 200, child: field),
          if (_filtered)
            TextButton(
              key: const Key('trip-filters-clear'),
              onPressed: () => setState(_clearFilters),
              child: Text(l.clearAll),
            ),
        ],
      ),
    );
  }

  /// Phones and tablets: the filters in a bottom sheet. Each change applies
  /// at once (the list behind updates); Apply closes the sheet.
  Future<void> _showFilters() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => Consumer(
      builder: (context, ref, _) => StatefulBuilder(
        builder: (context, setSheetState) {
          // Change the screen's filters and redraw the sheet with them.
          void update(VoidCallback change) {
            setState(change);
            setSheetState(() {});
          }

          return TripFiltersSheet(
            fields: _filterFields(context, ref, update),
            filtered: _filtered,
            onClear: () => update(_clearFilters),
          );
        },
      ),
    ),
  );

  /// The four filters (status, dates, driver, vehicle); [update] applies a
  /// change and redraws whoever shows them.
  List<Widget> _filterFields(
    BuildContext context,
    WidgetRef ref,
    void Function(VoidCallback) update,
  ) {
    final l = context.l10n;
    final fmt = context.fmt;
    final drivers = ref.watch(driversProvider).value ?? const <Driver>[];
    final vehicles =
        ref.watch(fleetVehiclesProvider).value ?? const <Vehicle>[];
    final days = _days;
    return [
      MultiSelectField(
        id: 'trip-status-filter',
        label: l.status,
        allLabel: l.allStatuses,
        options: [for (final s in tripStatuses) (s, statusLabel(l, s))],
        selected: _statuses,
        onChanged: (v) => update(() => _statuses = v),
      ),
      InputDecorator(
        key: const Key('trip-date-filter'),
        decoration: InputDecoration(
          labelText: l.dateRangeLabel,
          isDense: true,
          suffixIcon: days == null
              ? const Icon(Icons.calendar_today, size: 18)
              : IconButton(
                  tooltip: l.anyDate,
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => update(() => _days = null),
                ),
        ),
        child: InkWell(
          onTap: () async {
            final picked = await pickIsoRange(
              context,
              value: days,
              last: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) update(() => _days = picked);
          },
          child: Text(
            days == null
                ? l.anyDate
                : days.$1 == days.$2
                ? fmt.calendarDate(days.$1)
                : '${fmt.calendarDate(days.$1)} – '
                      '${fmt.calendarDate(days.$2)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      MultiSelectField(
        id: 'trip-driver-filter',
        label: l.driver,
        allLabel: l.allDrivers,
        options: [
          for (final d in drivers)
            if (d.isActive || _driverIds.contains(d.id)) (d.id, d.name),
        ],
        selected: _driverIds,
        onChanged: (v) => update(() => _driverIds = v),
      ),
      MultiSelectField(
        id: 'trip-vehicle-filter',
        label: l.vehicle,
        allLabel: l.allVehicles,
        options: [
          for (final v in vehicles)
            (v.id, formatRegistration(v.registrationNo)),
        ],
        selected: _vehicleIds,
        onChanged: (v) => update(() => _vehicleIds = v),
      ),
    ];
  }
}

/// The trip filters as a bottom sheet: [fields] in a column, Clear all while
/// [filtered], and Apply to close.
class TripFiltersSheet extends StatelessWidget {
  const TripFiltersSheet({
    required this.fields,
    required this.filtered,
    required this.onClear,
    super.key,
  });

  final List<Widget> fields;
  final bool filtered;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('trip-filters-sheet'),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.filters,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (filtered)
                  TextButton(
                    key: const Key('trip-filters-clear'),
                    onPressed: onClear,
                    child: Text(l.clearAll),
                  ),
              ],
            ),
            for (final field in fields) ...[const SizedBox(height: 16), field],
            const SizedBox(height: 24),
            ElevatedButton(
              key: const Key('trip-filters-apply'),
              onPressed: () => Navigator.pop(context),
              child: Text(l.apply),
            ),
          ],
        ),
      ),
    );
  }
}

/// A trip status as a coloured pill: amber when it needs a vehicle, blue when
/// planned or under way, green once settled, red when cancelled.
Tone tripStatusTone(String status) => switch (status) {
  'created' => Tone.warning,
  'assigned' => Tone.brand,
  'started' => Tone.brand,
  'settled' => Tone.success,
  'cancelled' => Tone.danger,
  _ => Tone.neutral,
};

/// [trips] split into runs that start on the same IST day, in list order, as
/// (YYYY-MM-DD, trips) pairs.
List<(String, List<Trip>)> groupTripsByDay(List<Trip> trips) {
  final groups = <(String, List<Trip>)>[];
  for (final t in trips) {
    final day = istDate(t.scheduledStartAt);
    if (groups.isNotEmpty && groups.last.$1 == day) {
      groups.last.$2.add(t);
    } else {
      groups.add((day, [t]));
    }
  }
  return groups;
}

/// "Today", "Tomorrow", "Yesterday", else "12 Oct 2026", for an IST [day].
String tripDayLabel(BuildContext context, String day, {DateTime? now}) {
  final l = context.l10n;
  final at = now ?? DateTime.now();
  if (day == istToday(at)) return l.today;
  if (day == istDate(at.add(const Duration(days: 1)))) return l.tomorrow;
  if (day == istDaysAgo(1, at)) return l.yesterday;
  return context.fmt.calendarDate(day);
}

/// Trips as a table on the desktop: route, start, vehicle, driver, customer,
/// fare and status; a click opens the trip.
class TripTable extends StatelessWidget {
  const TripTable(this.trips, {super.key});
  final List<Trip> trips;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final muted = TextStyle(color: context.tc.muted);
    return DesktopTable(
      key: const Key('trip-table'),
      columns: [
        TableColumn(l.colRoute, flex: 5),
        TableColumn(l.starts, flex: 3),
        TableColumn(l.vehicle, flex: 3),
        TableColumn(l.driver, flex: 3),
        TableColumn(l.colCustomer, flex: 3),
        TableColumn(l.colFare, end: true),
        TableColumn(l.status),
      ],
      rows: [
        for (final (day, group) in groupTripsByDay(trips)) ...[
          TableRowData.heading(
            tripDayLabel(context, day),
            key: ValueKey('trip-day-$day'),
          ),
          for (final t in group)
            TableRowData(
              key: ValueKey('owner-trip-${t.id}'),
              onTap: () => openScreen<void>(
                context,
                OwnerTripDetailScreen(tripId: t.id),
              ),
              cells: [
                Row(
                  children: [
                    Icon(
                      t.status == 'started' ? Icons.local_taxi : Icons.route,
                      size: 18,
                      color: context.tc.blue700,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        t.toText == null
                            ? l.localTrip(from: t.fromText)
                            : t.routeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                Text(fmt.dayTime(t.scheduledStartAt)),
                if (t.vehicle == null)
                  Text(l.unassigned, style: muted)
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formatRegistration(t.vehicle!.registrationNo)),
                      if (t.vehicle!.model.trim().isNotEmpty)
                        Text(
                          t.vehicle!.model,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: muted.copyWith(fontSize: 12),
                        ),
                    ],
                  ),
                Text(t.driverName ?? '–', style: muted),
                Text(
                  t.customerName ?? '–',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: muted,
                ),
                Text(
                  fmt.inr(t.quotedFarePaise),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ToneChip(
                        statusLabel(l, t.status),
                        tone: tripStatusTone(t.status),
                      ),
                    ),
                    if (t.cancellationPending)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.hourglass_top,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ],
    );
  }
}

/// A trip in owner lists: route, when, vehicle and driver, fare, status.
class OwnerTripTile extends StatelessWidget {
  const OwnerTripTile(this.trip, {super.key});
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final t = trip;
    final who = t.vehicle == null
        ? l.unassigned
        : [vehicleLabel(t.vehicle!), ?t.driverName].join(' · ');
    final tc = context.tc;
    Widget line(IconData icon, String text) => Row(
      children: [
        Icon(icon, size: 16, color: tc.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: tc.muted, fontSize: 13.5),
          ),
        ),
      ],
    );
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('owner-trip-${t.id}'),
        onTap: () =>
            openScreen<void>(context, OwnerTripDetailScreen(tripId: t.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ToneChip(
                    statusLabel(l, t.status),
                    tone: tripStatusTone(t.status),
                  ),
                  if (t.cancellationPending)
                    const Padding(
                      padding: EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.hourglass_top,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                  const Spacer(),
                  Text(
                    fmt.inr(t.quotedFarePaise),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                t.toText == null ? l.localTrip(from: t.fromText) : t.routeLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              line(Icons.schedule, fmt.dayTime(t.scheduledStartAt)),
              const SizedBox(height: 4),
              line(Icons.directions_car_outlined, who),
              if (t.customerName != null) ...[
                const SizedBox(height: 4),
                line(Icons.person_outline, t.customerName!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
