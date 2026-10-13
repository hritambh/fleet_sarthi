import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/api/models.dart';
import '../../../core/api/owner_api.dart';
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
  late String? _status = widget.initialStatus;
  String? _date;
  String? _driverId;
  String? _vehicleId;

  TripFilter get _filter {
    final range = _date == null ? null : istDayRange(_date!);
    return TripFilter(
      status: _status,
      driverId: _driverId,
      vehicleId: _vehicleId,
      from: range?.$1,
      to: range?.$2,
    );
  }

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
                : Column(children: [for (final t in list) OwnerTripTile(t)]),
          ),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context) {
    final l = context.l10n;
    Widget box(Widget child) => SizedBox(width: 200, child: child);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          box(
            DropdownButtonFormField<String?>(
              key: const Key('trip-status-filter'),
              initialValue: _status,
              isExpanded: true,
              decoration: InputDecoration(labelText: l.status, isDense: true),
              items: [
                DropdownMenuItem<String?>(child: Text(l.allStatuses)),
                for (final s in tripStatuses)
                  DropdownMenuItem<String?>(
                    value: s,
                    child: Text(statusLabel(l, s)),
                  ),
              ],
              onChanged: (v) => setState(() => _status = v),
            ),
          ),
          box(
            InputDecorator(
              decoration: InputDecoration(
                labelText: l.pickDate,
                isDense: true,
                suffixIcon: _date == null
                    ? const Icon(Icons.calendar_today, size: 18)
                    : IconButton(
                        tooltip: l.anyDate,
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => setState(() => _date = null),
                      ),
              ),
              child: InkWell(
                onTap: () async {
                  final picked = await pickIsoDate(
                    context,
                    value: _date,
                    last: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: Text(
                  _date == null ? l.anyDate : context.fmt.calendarDate(_date!),
                ),
              ),
            ),
          ),
          box(
            DriverPicker(
              value: _driverId,
              label: l.driver,
              noneLabel: l.allDrivers,
              onChanged: (v) => setState(() => _driverId = v),
            ),
          ),
          box(
            VehiclePicker(
              value: _vehicleId,
              label: l.vehicle,
              noneLabel: l.allVehicles,
              activeOnly: false,
              onChanged: (v) => setState(() => _vehicleId = v),
            ),
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
        for (final t in trips)
          TableRowData(
            key: ValueKey('owner-trip-${t.id}'),
            onTap: () =>
                openScreen<void>(context, OwnerTripDetailScreen(tripId: t.id)),
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
