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
        actions: [const AlertsBell(), ...action.headerActions(context)],
      ),
      floatingActionButton: action.fab(context),
      body: RefreshPage(
        onRefresh: () => ref.refresh(ownerTripsProvider(_filter).future),
        children: [
          _filters(context),
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

  Widget _filters(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final drivers = ref.watch(driversProvider).value ?? const <Driver>[];
    final vehicles =
        ref.watch(fleetVehiclesProvider).value ?? const <Vehicle>[];
    final days = _days;
    Widget box(Widget child) => SizedBox(width: 200, child: child);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          box(
            MultiSelectField(
              id: 'trip-status-filter',
              label: l.status,
              allLabel: l.allStatuses,
              options: [for (final s in tripStatuses) (s, statusLabel(l, s))],
              selected: _statuses,
              onChanged: (v) => setState(() => _statuses = v),
            ),
          ),
          box(
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
                        onPressed: () => setState(() => _days = null),
                      ),
              ),
              child: InkWell(
                onTap: () async {
                  final picked = await pickIsoRange(
                    context,
                    value: days,
                    last: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _days = picked);
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
          ),
          box(
            MultiSelectField(
              id: 'trip-driver-filter',
              label: l.driver,
              allLabel: l.allDrivers,
              options: [
                for (final d in drivers)
                  if (d.isActive || _driverIds.contains(d.id)) (d.id, d.name),
              ],
              selected: _driverIds,
              onChanged: (v) => setState(() => _driverIds = v),
            ),
          ),
          box(
            MultiSelectField(
              id: 'trip-vehicle-filter',
              label: l.vehicle,
              allLabel: l.allVehicles,
              options: [
                for (final v in vehicles)
                  (v.id, formatRegistration(v.registrationNo)),
              ],
              selected: _vehicleIds,
              onChanged: (v) => setState(() => _vehicleIds = v),
            ),
          ),
          if (_filtered)
            TextButton(
              key: const Key('trip-filters-clear'),
              onPressed: () => setState(() {
                _statuses = {};
                _driverIds = {};
                _vehicleIds = {};
                _days = null;
              }),
              child: Text(l.clearAll),
            ),
        ],
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
    const muted = TextStyle(color: TaxcyColors.muted);
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
                      color: TaxcyColors.blue700,
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
                Text(
                  t.vehicle == null
                      ? l.unassigned
                      : formatRegistration(t.vehicle!.registrationNo),
                  style: t.vehicle == null ? muted : null,
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
        : [
            formatRegistration(t.vehicle!.registrationNo),
            ?t.driverName,
          ].join(' · ');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        key: ValueKey('owner-trip-${t.id}'),
        leading: CircleAvatar(
          backgroundColor: TaxcyColors.blue50,
          foregroundColor: TaxcyColors.blue700,
          child: Icon(
            t.status == 'started' ? Icons.local_taxi : Icons.route,
            size: 20,
          ),
        ),
        title: Text(
          t.toText == null ? l.localTrip(from: t.fromText) : t.routeLabel,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            fmt.dayTime(t.scheduledStartAt),
            who,
            if (t.customerName != null) t.customerName!,
          ].join(' · '),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(fmt.inr(t.quotedFarePaise)),
            if (t.cancellationPending)
              const Icon(Icons.hourglass_top, size: 16, color: Colors.amber)
            else
              Text(
                statusLabel(l, t.status),
                style: const TextStyle(fontSize: 12, color: TaxcyColors.muted),
              ),
          ],
        ),
        onTap: () =>
            openScreen<void>(context, OwnerTripDetailScreen(tripId: t.id)),
      ),
    );
  }
}
