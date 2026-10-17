import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/repositories/trips_repository.dart';
import '../common/format.dart';
import '../common/widgets.dart';
import '../owner/owner_text.dart';
import '../owner/owner_widgets.dart';
import '../owner/trip_schedule.dart';
import '../trips/driver_home.dart';
import 'driver_providers.dart';

/// The driver's trips: what's assigned to them (from the phone, so it works
/// offline), past trips month by month, and their schedule calendar.
class DriverTripsScreen extends StatelessWidget {
  const DriverTripsScreen({this.now, super.key});

  /// Today, for tests; defaults to the clock.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.myTrips),
          bottom: ownerTabBar(context, [
            Tab(key: const Key('driver-tab-assigned'), text: l.assignedTab),
            Tab(key: const Key('driver-tab-past'), text: l.pastTab),
            Tab(key: const Key('driver-tab-schedule'), text: l.schedule),
          ]),
        ),
        body: TabBarView(
          children: [
            const _AssignedTrips(),
            _PastTrips(now: now),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: TripSchedule.mine(
                now: now,
                tripTile: (t) => _RemoteTripTile(t),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignedTrips extends ConsumerWidget {
  const _AssignedTrips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final trips = ref.watch(tripsProvider);
    return RefreshIndicator(
      onRefresh: () => ref.read(syncEngineProvider).syncNow(),
      child: trips.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ListView(children: [EmptyState('$error')]),
        data: (list) {
          final assigned =
              list
                  .where(
                    (v) =>
                        v.trip.status == 'assigned' ||
                        v.trip.status == 'started',
                  )
                  .toList()
                ..sort(
                  (a, b) => a.trip.scheduledStartAt.compareTo(
                    b.trip.scheduledStartAt,
                  ),
                );
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (assigned.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyState(l.noAssignedTrips),
                ),
              for (final v in assigned) _Readable(DriverTripTile(v)),
            ],
          );
        },
      ),
    );
  }
}

/// Completed and cancelled trips, one month at a time, newest first.
class _PastTrips extends ConsumerStatefulWidget {
  const _PastTrips({this.now});
  final DateTime? now;

  @override
  ConsumerState<_PastTrips> createState() => _PastTripsState();
}

class _PastTripsState extends ConsumerState<_PastTrips> {
  late final DateTime _thisMonth = () {
    final today = DateTime.parse(istToday(widget.now));
    return DateTime(today.year, today.month);
  }();
  late DateTime _month = _thisMonth;

  static String _iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-01';

  /// The month's IST bounds.
  TripRange get _range => (
    from: istDayRange(_iso(_month)).$1,
    to: istDayRange(_iso(DateTime(_month.year, _month.month + 1))).$1,
  );

  static const _done = {'ended', 'settled', 'cancelled'};

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final trips = ref.watch(myTripsBetweenProvider(_range));
    final latest = !_month.isBefore(_thisMonth);
    return RefreshPage(
      onRefresh: () => ref.refresh(myTripsBetweenProvider(_range).future),
      children: [
        Row(
          children: [
            IconButton(
              key: const Key('past-prev'),
              tooltip: l.previousMonth,
              icon: const Icon(Icons.chevron_left),
              onPressed: () => setState(
                () => _month = DateTime(_month.year, _month.month - 1),
              ),
            ),
            Expanded(
              child: Text(
                fmt.dateFormat('yMMMM').format(_month),
                key: const Key('past-month'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              key: const Key('past-next'),
              tooltip: l.nextMonth,
              icon: const Icon(Icons.chevron_right),
              onPressed: latest
                  ? null
                  : () => setState(
                      () => _month = DateTime(_month.year, _month.month + 1),
                    ),
            ),
          ],
        ),
        AsyncView(
          value: trips,
          onRetry: () => ref.invalidate(myTripsBetweenProvider(_range)),
          builder: (list) {
            final past = list.where((t) => _done.contains(t.status)).toList()
              ..sort(
                (a, b) => b.scheduledStartAt.compareTo(a.scheduledStartAt),
              );
            if (past.isEmpty) return EmptyState(l.noPastTrips);
            return Column(children: [for (final t in past) _RemoteTripTile(t)]);
          },
        ),
      ],
    );
  }
}

/// A trip fetched from the server: opens the full trip when it's on the
/// phone, otherwise a summary.
class _RemoteTripTile extends ConsumerWidget {
  const _RemoteTripTile(this.trip);
  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = ref
        .watch(tripsProvider)
        .value
        ?.where((v) => v.trip.id == trip.id)
        .firstOrNull;
    return _Readable(
      DriverTripTile(
        local ?? TripView(trip),
        onTap: local != null ? null : () => showTripSummary(context, trip),
      ),
    );
  }
}

/// A past trip's details: when, the cab, the customer, the odometer and fare.
Future<void> showTripSummary(BuildContext context, Trip t) =>
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (sheet) {
        final l = sheet.l10n;
        final fmt = sheet.fmt;
        final start = t.startOdometer?.typedKm;
        final end = t.endOdometer?.typedKm;
        Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                child: Text(label, style: TextStyle(color: context.tc.muted)),
              ),
              Expanded(child: Text(value)),
            ],
          ),
        );
        return Padding(
          key: const Key('trip-summary'),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.routeLabel,
                      style: Theme.of(sheet).textTheme.titleMedium,
                    ),
                  ),
                  StatusChip(t.status),
                ],
              ),
              const SizedBox(height: 12),
              row(
                l.when,
                '${fmt.dayTime(t.scheduledStartAt)} – '
                '${fmt.time(t.scheduledEndAt)}',
              ),
              if (t.vehicle != null)
                row(
                  l.vehicle,
                  [
                    if (t.vehicle!.model.isNotEmpty) t.vehicle!.model,
                    formatRegistration(t.vehicle!.registrationNo),
                  ].join(' · '),
                ),
              if (t.customerName != null) row(l.customer, t.customerName!),
              if (start != null)
                row(l.odometer, l.startOdometerKm(km: fmt.number(start))),
              if (end != null) row('', l.endOdometerKm(km: fmt.number(end))),
              if (start != null && end != null && end >= start)
                row('', fmt.km(end - start)),
              row(l.fare, fmt.inr(t.quotedFarePaise)),
            ],
          ),
        );
      },
    );

/// A readable column on a wide screen (the web app).
class _Readable extends StatelessWidget {
  const _Readable(this.child);
  final Widget child;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: child,
    ),
  );
}
