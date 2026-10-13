import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/repositories/trips_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/format.dart';
import '../common/widgets.dart';
import '../fuel/fuel_fill_screen.dart';
import '../owner/owner_text.dart';
import '../owner/trips/trip_share.dart' show urlOpenerProvider;
import 'driver_summary.dart';
import 'new_trip_screen.dart';
import 'trip_detail_screen.dart';

/// Ticks every 30 s so countdowns and "on the road for" times stay current.
final driverClockProvider = StreamProvider.autoDispose<DateTime>(
  (ref) => Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now()),
);

DateTime _now(WidgetRef ref) =>
    ref.watch(driverClockProvider).value ?? DateTime.now();

/// "2 h 05 min" / "45 min".
String shortDuration(AppLocalizations l, Duration d) {
  final minutes = d.inMinutes.abs();
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return h > 0
      ? l.durationHm(h: h, m: m.toString().padLeft(2, '0'))
      : l.durationM(m: m);
}

void _openTrip(BuildContext context, TripView view) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TripDetailScreen(tripId: view.trip.id),
      ),
    );

/// Directions in the maps app to [point], or to [text] when there's no pin.
Uri directionsUri(GeoPoint? point, String text) =>
    Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': point == null ? text : '${point.lat},${point.lng}',
    });

/// Who's driving today: a greeting, the date and the fleet.
class DriverHeader extends ConsumerWidget {
  const DriverHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final session = ref.watch(authProvider).value;
    final name = session?.name ?? '';
    final now = _now(ref);
    final fleet = session?.activeMembership?.orgName;
    return Container(
      key: const Key('driver-header'),
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [TaxcyColors.blue700, TaxcyColors.blue950],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            foregroundColor: Colors.white,
            child: name.isEmpty
                ? const Icon(Icons.person)
                : Text(
                    name
                        .trim()
                        .split(RegExp(r'\s+'))
                        .take(2)
                        .map((w) => w[0].toUpperCase())
                        .join(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting(l, now, name.trim().split(' ').first),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    context.fmt.calendarDate(
                      '${now.year}-${now.month.toString().padLeft(2, '0')}-'
                      '${now.day.toString().padLeft(2, '0')}',
                    ),
                    ?fleet,
                  ].join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: TaxcyColors.blue200),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The trip under way: how long, how far by GPS, what's been collected.
class ActiveTripCard extends ConsumerWidget {
  const ActiveTripCard(this.view, {super.key});
  final TripView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = context.fmt;
    final t = view.trip;
    final now = _now(ref);
    final gpsKm = ref.watch(tripDistanceProvider(t.id)).value ?? 0;
    final collected = t.collections.fold<int>(0, (s, c) => s + c.amountPaise);
    const onBlue = TextStyle(color: Colors.white);
    Widget fact(IconData icon, String text) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: TaxcyColors.blue200),
        const SizedBox(width: 4),
        Text(text, style: onBlue.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
    return Card(
      key: const Key('driver-active-trip'),
      color: TaxcyColors.blue700,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openTrip(context, view),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_taxi, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.tripInProgress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: onBlue.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (t.vehicle != null)
                    Text(
                      formatRegistration(t.vehicle!.registrationNo),
                      style: const TextStyle(color: TaxcyColors.blue200),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                t.routeLabel,
                style: onBlue.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  if (t.startedAt != null)
                    fact(
                      Icons.timer_outlined,
                      shortDuration(l, now.difference(t.startedAt!)),
                    ),
                  fact(Icons.route, l.kmSoFar(km: fmt.km(gpsKm.round()))),
                  if (collected > 0)
                    fact(Icons.payments_outlined, fmt.inr(collected)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('driver-open-active'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: TaxcyColors.blue800,
                      ),
                      onPressed: () => _openTrip(context, view),
                      icon: const Icon(Icons.arrow_forward),
                      label: Text(l.openTrip),
                    ),
                  ),
                  if (t.toText != null) ...[
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: l.directions,
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: TaxcyColors.blue300),
                      ),
                      onPressed: () => ref.read(urlOpenerProvider)(
                        directionsUri(t.toPoint, t.toText!),
                      ),
                      icon: const Icon(Icons.directions),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The next assigned trip: when it starts, where, for whom, in which car.
class NextTripCard extends ConsumerWidget {
  const NextTripCard(this.view, {super.key});
  final TripView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = context.fmt;
    final t = view.trip;
    final until = t.scheduledStartAt.difference(_now(ref));
    final (countdown, tone) = until.inMinutes > 0
        ? (l.startsIn(time: shortDuration(l, until)), TaxcyColors.blue700)
        : until.inMinutes > -10
        ? (l.startingNow, Colors.green.shade700)
        : (l.runningLate(time: shortDuration(l, until)), Colors.red.shade700);
    final opener = ref.read(urlOpenerProvider);
    return Card(
      key: const Key('driver-next-trip'),
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openTrip(context, view),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: TaxcyColors.blue600, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.nextTrip,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      countdown,
                      key: const Key('driver-next-countdown'),
                      style: TextStyle(
                        color: tone,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t.routeLabel,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                [
                  fmt.dayTime(t.scheduledStartAt),
                  if (t.vehicle != null)
                    formatRegistration(t.vehicle!.registrationNo),
                  fmt.inr(t.quotedFarePaise),
                ].join(' · '),
                style: const TextStyle(color: TaxcyColors.muted),
              ),
              if (t.customerName != null || t.customerPhone != null) ...[
                const Divider(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 20,
                      color: TaxcyColors.muted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        t.customerName ?? formatPhone(t.customerPhone!),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (t.customerPhone != null)
                      IconButton.filledTonal(
                        key: const Key('driver-call-customer'),
                        tooltip: l.callCustomer,
                        onPressed: () =>
                            opener(Uri(scheme: 'tel', path: t.customerPhone)),
                        icon: const Icon(Icons.call, size: 20),
                      ),
                    IconButton.filledTonal(
                      key: const Key('driver-directions'),
                      tooltip: l.directions,
                      onPressed: () =>
                          opener(directionsUri(t.fromPoint, t.fromText)),
                      icon: const Icon(Icons.directions, size: 20),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A period's numbers as three tiles under a heading.
class DriverStatsCard extends StatelessWidget {
  const DriverStatsCard({
    required this.title,
    required this.stats,
    this.showTotal = false,
    super.key,
  });

  final String title;
  final DriverStats stats;

  /// "2 of 3" (today) instead of just the trips done.
  final bool showTotal;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    Widget tile(IconData icon, String value, String label, [String? hint]) =>
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: TaxcyColors.blue600),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TaxcyColors.blue950,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: TaxcyColors.muted),
              ),
              if (hint != null)
                Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: TaxcyColors.muted,
                  ),
                ),
            ],
          ),
        );
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                tile(
                  Icons.check_circle_outline,
                  showTotal
                      ? l.ofTotal(
                          done: stats.tripsDone,
                          total: stats.tripsTotal,
                        )
                      : fmt.number(stats.tripsDone),
                  l.statTripsDone,
                ),
                const SizedBox(width: 8),
                tile(Icons.speed, fmt.km(stats.km), l.statKmDriven),
                const SizedBox(width: 8),
                tile(
                  Icons.payments_outlined,
                  fmt.inr(stats.collectedPaise),
                  l.statCollected,
                  stats.cashPaise > 0
                      ? l.cashAmount(amount: fmt.inr(stats.cashPaise))
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Things a driver does between trips.
class DriverQuickActions extends ConsumerWidget {
  const DriverQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    Widget action(Key key, IconData icon, String label, VoidCallback onTap) =>
        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: key,
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  children: [
                    Icon(icon, color: TaxcyColors.blue700),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          action(
            const Key('driver-action-new-trip'),
            Icons.add_road,
            l.newTrip,
            () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const NewTripScreen()),
            ),
          ),
          const SizedBox(width: 8),
          action(
            const Key('driver-action-fuel'),
            Icons.local_gas_station,
            l.logFuel,
            () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const FuelFillScreen()),
            ),
          ),
          const SizedBox(width: 8),
          action(
            const Key('driver-action-sync'),
            Icons.sync,
            l.syncNow,
            () => ref.read(syncEngineProvider).syncNow(),
          ),
        ],
      ),
    );
  }
}

/// No trips on the phone yet.
class DriverEmptyState extends StatelessWidget {
  const DriverEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: TaxcyColors.blue50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.route,
              size: 36,
              color: TaxcyColors.blue600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.noTripsAssigned,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            l.noTripsHint,
            textAlign: TextAlign.center,
            style: const TextStyle(color: TaxcyColors.muted),
          ),
        ],
      ),
    );
  }
}

/// A section heading in the trip list.
class TripSectionHeader extends StatelessWidget {
  const TripSectionHeader(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

/// The trip-list row: time on the left, route, car, customer and fare.
/// Tapping opens the trip, or runs [onTap] (a trip that isn't on the phone).
class DriverTripTile extends StatelessWidget {
  const DriverTripTile(this.view, {this.onTap, super.key});
  final TripView view;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = view.trip;
    final l = context.l10n;
    final fmt = context.fmt;
    final active = t.status == 'started';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('driver-trip-${t.id}'),
        onTap: onTap ?? () => _openTrip(context, view),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 64,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? TaxcyColors.blue700 : TaxcyColors.blue50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(
                      active ? Icons.local_taxi : Icons.schedule,
                      size: 18,
                      color: active ? Colors.white : TaxcyColors.blue700,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fmt.time(t.scheduledStartAt),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : TaxcyColors.blue900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.routeLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        fmt.dayTime(t.scheduledStartAt),
                        if (t.vehicle != null) t.vehicle!.registrationNo,
                        ?t.customerName,
                        if (view.conflict != null)
                          '⚠ ${view.conflict == 'TRIP_CANCELLED' ? l.conflictCancelledShort : l.conflictReassignedShort}',
                      ].join(' · '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: TaxcyColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusChip(t.status),
                  const SizedBox(height: 4),
                  Text(
                    fmt.inr(t.quotedFarePaise),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
