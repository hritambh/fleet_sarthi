import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/api/owner_api.dart';
import '../../core/api/owner_models.dart';
import '../../l10n/app_localizations.dart';
import '../common/format.dart';
import '../common/magnetic_field_background.dart';
import '../common/widgets.dart';
import 'alerts_inbox.dart';
import 'alerts_screen.dart';
import 'cab_timeline.dart';
import 'owner_providers.dart';
import 'owner_text.dart';
import 'owner_widgets.dart';
import 'people_screens.dart';
import 'trips/create_trip_screen.dart';
import 'trips/owner_trip_detail_screen.dart';
import 'trips/owner_trips_screen.dart';
import 'vehicles_screen.dart';

const _severityOrder = {'critical': 0, 'warning': 1, 'info': 2};

enum _Day { today, yesterday, custom }

/// A day at a glance: headline cards (cabs and drivers free right now, each
/// cab's day as a free/busy timeline, the unassigned queue, completed trips
/// and gross fare), the quick operations hub
/// (add a trip, driver or cab; assign a waiting trip), that day's scheduled
/// rides and the most urgent open alerts. The date switch picks the day. On a
/// desktop-sized screen: a greeting and two columns.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({required this.onOpenTrips, this.now, super.key});

  /// Switches the owner shell to the Trips section.
  final VoidCallback onOpenTrips;

  /// Today, for tests; defaults to the clock.
  final DateTime? now;

  static TripFilter dayFilter(String date) {
    final (from, to) = istDayRange(date);
    return TripFilter(from: from, to: to);
  }

  static TripFilter todayFilter([DateTime? now]) => dayFilter(istToday(now));

  /// Trips overlapping the IST day, for the cabs' timelines (a trip from
  /// the night before still holds its cab after midnight).
  static TripFilter timelineFilter(String date) {
    final (from, to) = istDayRange(date);
    return TripFilter(from: from, to: to, overlapping: true);
  }

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static final _openAlerts = alertQuery(statuses: {'open'});

  var _day = _Day.today;
  String? _custom;

  String get _date => switch (_day) {
    _Day.today => istToday(widget.now),
    _Day.yesterday => istDaysAgo(1, widget.now),
    _Day.custom => _custom ?? istToday(widget.now),
  };

  Future<void> _pickDay(_Day day) async {
    if (day != _Day.custom) {
      setState(() => _day = day);
      return;
    }
    final today = DateTime.parse(istToday(widget.now));
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_date),
      firstDate: today.subtract(const Duration(days: 365 * 3)),
      lastDate: today.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _day = _Day.custom;
      _custom = istDate(DateTime.utc(picked.year, picked.month, picked.day));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final date = _date;
    final filter = DashboardScreen.dayFilter(date);
    final trips = ref.watch(ownerTripsProvider(filter));
    final headline = ref.watch(dashboardSummaryProvider(date));
    final alerts = ref.watch(alertsProvider(_openAlerts));
    final desktop = isDesktop(context);

    final daySwitch = SegmentedButton<_Day>(
      key: const Key('dashboard-day'),
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: _Day.today, label: Text(l.today)),
        ButtonSegment(value: _Day.yesterday, label: Text(l.yesterday)),
        ButtonSegment(
          value: _Day.custom,
          icon: const Icon(Icons.calendar_today, size: 16),
          label: Text(
            _day == _Day.custom ? fmt.calendarDate(date) : l.customDay,
          ),
        ),
      ],
      selected: {_day},
      onSelectionChanged: (s) => _pickDay(s.first),
    );

    // Each cab's day; until both lists load, the cabs card shows its plain
    // progress and footer instead.
    final timelineFilter = DashboardScreen.timelineFilter(date);
    final dayTrips = ref.watch(ownerTripsProvider(timelineFilter)).value;
    final vehicles = ref.watch(fleetVehiclesProvider).value;
    final clock = widget.now ?? DateTime.now();
    final (dayStart, dayEnd) = istDayRange(date);
    final cabs = dayTrips == null || vehicles == null || vehicles.isEmpty
        ? null
        : cabDays(
            vehicles: vehicles,
            trips: dayTrips,
            dayStart: dayStart,
            now: clock,
          );
    final nowAt = clock.isBefore(dayStart) || !clock.isBefore(dayEnd)
        ? null
        : clock.difference(dayStart).inMilliseconds /
              const Duration(days: 1).inMilliseconds;

    final cards = AsyncView(
      value: headline,
      onRetry: () => ref.invalidate(dashboardSummaryProvider(date)),
      builder: (s) => _HeadlineCards(
        s,
        cabs: cabs,
        nowAt: nowAt,
        onOpenTrips: widget.onOpenTrips,
      ),
    );

    const hub = _QuickOpsHub();

    // Every trip of the day, cancelled ones too, in start order.
    final rides = SectionCard(
      key: const Key('scheduled-rides'),
      title: _day == _Day.today
          ? l.scheduledRides
          : l.scheduledRidesOn(date: fmt.calendarDate(date)),
      actions: [
        TextButton(onPressed: widget.onOpenTrips, child: Text(l.seeAll)),
      ],
      child: AsyncView(
        value: trips,
        onRetry: () => ref.invalidate(ownerTripsProvider(filter)),
        builder: (list) {
          if (list.isEmpty) {
            return EmptyState(
              _day == _Day.today ? l.noTripsToday : l.noTripsThisDay,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final t
                  in [...list]..sort(
                    (a, b) => a.scheduledStartAt.compareTo(b.scheduledStartAt),
                  ))
                _RideTile(t),
            ],
          );
        },
      ),
    );
    final openAlerts = SectionCard(
      title: l.openAlerts,
      actions: [
        TextButton(
          onPressed: () => openAlertsInbox(context),
          child: Text(l.seeAll),
        ),
      ],
      child: AsyncView(
        value: alerts,
        onRetry: () => ref.invalidate(alertsProvider(_openAlerts)),
        builder: (list) {
          if (list.isEmpty) return EmptyState(l.noOpenAlerts);
          final sorted = [...list]..sort(_bySeverityThenNewest);
          return Column(
            children: [
              for (final a in sorted.take(6)) AlertCard(a, compact: true),
            ],
          );
        },
      ),
    );

    Future<void> refresh() async {
      ref
        ..invalidate(dashboardSummaryProvider(date))
        ..invalidate(alertsProvider(_openAlerts))
        ..invalidate(driversProvider)
        ..invalidate(fleetVehiclesProvider)
        ..invalidate(ownerTripsProvider(timelineFilter))
        ..invalidate(ownerTripsProvider(filter));
      await ref.read(ownerTripsProvider(filter).future);
    }

    final appBar = AppBar(
      title: Text(l.navDashboard),
      actions: const [AlertsBell()],
    );

    if (!desktop) {
      return Scaffold(
        appBar: appBar,
        body: RefreshPage(
          onRefresh: refresh,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: daySwitch,
              ),
            ),
            const SizedBox(height: 8),
            cards,
            const SizedBox(height: 8),
            hub,
            rides,
            openAlerts,
          ],
        ),
      );
    }

    final session = ref.watch(authProvider).value;
    final firstName = (session?.name ?? '').trim().split(' ').first;
    return Scaffold(
      appBar: appBar,
      // A field of fine dots across the whole page, waves passing through it
      // and reacting to the pointer (desktop only; still when reduced motion
      // is on). The cards are slightly see-through so it shows behind them,
      // and turn solid under the pointer.
      body: MagneticFieldBackground(
        child: Theme(
          data: Theme.of(context).copyWith(
            cardTheme: Theme.of(
              context,
            ).cardTheme.copyWith(color: Colors.white.withValues(alpha: 0.58)),
          ),
          child: RefreshPage(
            onRefresh: refresh,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting(l, DateTime.now(), firstName),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: TaxcyColors.blue950,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${fmt.calendarDate(istToday(widget.now))}'
                      ' · ${session?.activeMembership?.orgName ?? ''}',
                      style: const TextStyle(color: TaxcyColors.muted),
                    ),
                    const SizedBox(height: 12),
                    daySwitch,
                  ],
                ),
              ),
              cards,
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        _SolidOnHover(child: rides),
                        _SolidOnHover(child: openAlerts),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(flex: 2, child: hub),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static int _bySeverityThenNewest(Alert a, Alert b) {
    final bySeverity = (_severityOrder[a.severity] ?? 3).compareTo(
      _severityOrder[b.severity] ?? 3,
    );
    return bySeverity != 0 ? bySeverity : b.createdAt.compareTo(a.createdAt);
  }
}

/// The four headline cards: in a row on the desktop, a 2×2 grid on phones.
class _HeadlineCards extends StatelessWidget {
  const _HeadlineCards(
    this.s, {
    required this.cabs,
    required this.nowAt,
    required this.onOpenTrips,
  });
  final DashboardSummary s;

  /// Each cab's day for the cabs card; null while loading.
  final List<CabDay>? cabs;

  /// Now as a share of the day, when the day is today.
  final double? nowAt;
  final VoidCallback onOpenTrips;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    double? share(int part, int total) => total == 0 ? null : part / total;
    final change = s.completedChangePercent;
    final free = cabs == null ? null : freeShare(cabs!);
    final cards = [
      KpiCard(
        key: const Key('kpi-cabs'),
        icon: Icons.local_taxi,
        accent: TaxcyColors.blue600,
        label: l.availableCabs,
        value: fmt.number(s.cabsAvailable),
        suffix: '/ ${fmt.number(s.cabsTotal)}',
        pill: s.cabsTotal == 0
            ? null
            : l.percentReady(
                percent: (s.cabsAvailable * 100 / s.cabsTotal).round(),
              ),
        progress: share(s.cabsAvailable, s.cabsTotal),
        footer: l.cabsFooter(onTrip: s.cabsOnTrip, inactive: s.cabsInactive),
        badge: free == null ? null : _FreeBadge(free),
        detail: cabs == null ? null : _CabTimelines(cabs!, nowAt: nowAt),
        onTap: () => openScreen<void>(context, const VehiclesScreen()),
      ),
      KpiCard(
        key: const Key('kpi-drivers'),
        icon: Icons.badge_outlined,
        accent: Colors.teal.shade600,
        label: l.availableDrivers,
        value: fmt.number(s.driversAvailable),
        suffix: '/ ${fmt.number(s.driversTotal)}',
        pill: s.driversAvailable > 0 ? l.standby : null,
        progress: share(s.driversAvailable, s.driversTotal),
        footer: l.driversFooter(
          onTrip: s.driversOnTrip,
          assigned: s.driversAssigned,
        ),
        onTap: () => openScreen<void>(context, const DriversScreen()),
      ),
      KpiCard(
        key: const Key('kpi-unassigned'),
        icon: Icons.warning_amber_rounded,
        accent: Colors.amber.shade800,
        label: l.tripsUnassigned,
        value: fmt.number(s.unassigned),
        suffix: l.pending,
        pill: s.unassigned > 0 ? l.needsCab : null,
        highlight: s.unassigned > 0,
        link: s.unassigned > 0 ? l.resolveQueue : null,
        onTap: () => openScreen<void>(
          context,
          const OwnerTripsScreen(initialStatus: 'created'),
        ),
      ),
      KpiCard(
        key: const Key('kpi-completed'),
        icon: Icons.task_alt,
        accent: Colors.green.shade700,
        label: l.completedTrips,
        value: fmt.number(s.completedCount),
        suffix: l.runs,
        pill: change == null ? null : '${change > 0 ? '+' : ''}$change%',
        footer: l.grossFare(amount: fmt.inr(s.completedGrossPaise)),
        onTap: onOpenTrips,
      ),
    ];
    Widget row(List<Widget> items, double gap) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, card) in items.indexed) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(child: _SolidOnHover(child: card)),
          ],
        ],
      ),
    );
    if (isDesktop(context)) return row(cards, 16);
    return Column(
      children: [
        row(cards.sublist(0, 2), 8),
        const SizedBox(height: 8),
        row(cards.sublist(2), 8),
      ],
    );
  }
}

/// The share of the day the active cabs are free, as a ring and a percent.
class _FreeBadge extends StatelessWidget {
  const _FreeBadge(this.free);

  final double free;

  @override
  Widget build(BuildContext context) {
    final percent = (free * 100).round();
    // Just the ring and number, so it fits a phone's half-width card; the
    // words are for screen readers and the tooltip.
    return Tooltip(
      message: context.l10n.percentFree(percent: percent),
      child: Semantics(
        label: context.l10n.percentFree(percent: percent),
        excludeSemantics: true,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FreeShareRing(free: free, size: 18),
              const SizedBox(width: 6),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF15803D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Each cab's day as a line, green where free and red where a trip holds
/// it, in a fixed height so the card keeps its size: up to four cabs, or
/// three and "+N more".
class _CabTimelines extends StatelessWidget {
  const _CabTimelines(this.days, {required this.nowAt});

  final List<CabDay> days;
  final double? nowAt;

  static const _rows = 4;
  static const _rowHeight = 12.0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final shown = days.length > _rows ? days.take(_rows - 1) : days;
    const label = TextStyle(
      fontSize: 10,
      height: 1.1,
      fontWeight: FontWeight.w600,
      color: TaxcyColors.muted,
    );
    return SizedBox(
      key: const Key('cab-timelines'),
      height: _rows * _rowHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final day in shown)
            SizedBox(
              height: _rowHeight,
              child: Semantics(
                label: l.cabHoursFree(
                  reg: day.registrationNo,
                  hours: ((1 - day.busyShare) * 24).round(),
                ),
                excludeSemantics: true,
                child: Row(
                  children: [
                    SizedBox(
                      width: 62,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(day.registrationNo, style: label),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: CabDayBar(day: day, nowAt: nowAt),
                    ),
                  ],
                ),
              ),
            ),
          if (days.length > _rows)
            SizedBox(
              height: _rowHeight,
              child: Text(
                l.moreCabs(count: days.length - (_rows - 1)),
                style: label.copyWith(color: TaxcyColors.blue700),
              ),
            ),
        ],
      ),
    );
  }
}

/// The "Quick Operations Hub": add a trip, assign a waiting trip, invite a
/// driver, add a cab. A section card like the others, with add trip as the
/// one filled (primary) action.
class _QuickOpsHub extends StatelessWidget {
  const _QuickOpsHub();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget row(Widget a, Widget b) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: a),
          const SizedBox(width: 8),
          Expanded(child: b),
        ],
      ),
    );
    return SectionCard(
      key: const Key('quick-ops'),
      title: l.quickOpsHub,
      actions: [
        Text(
          l.fastDispatch,
          style: const TextStyle(
            color: TaxcyColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row(
            _HubButton(
              key: const Key('quick-add-trip'),
              icon: Icons.add_circle_outline,
              label: l.addTrip,
              primary: true,
              onTap: () => openScreen<void>(context, const CreateTripScreen()),
            ),
            _HubButton(
              key: const Key('quick-tag-driver'),
              icon: Icons.link,
              label: l.tagDriver,
              onTap: () => showTagDriver(context),
            ),
          ),
          const SizedBox(height: 8),
          row(
            _HubButton(
              key: const Key('quick-add-driver'),
              icon: Icons.person_add_alt,
              label: l.addDriverQuick,
              onTap: () => inviteDriver(context),
            ),
            _HubButton(
              key: const Key('quick-add-cab'),
              icon: Icons.directions_car_outlined,
              label: l.addCabQuick,
              onTap: () => openScreen<void>(context, const VehicleFormScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

/// A hub tile: filled blue for the primary action, otherwise a light blue
/// tile with a blue icon, in the app's palette.
class _HubButton extends StatelessWidget {
  const _HubButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = primary ? Colors.white : TaxcyColors.ink;
    final iconColor = primary ? Colors.white : TaxcyColors.blue700;
    return Material(
      color: primary ? TaxcyColors.blue700 : TaxcyColors.blue50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: primary
            ? BorderSide.none
            : const BorderSide(color: TaxcyColors.blue100),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _route(AppLocalizations l, Trip t) =>
    t.toText == null ? l.localTrip(from: t.fromText) : t.routeLabel;

/// A ride on the dashboard: route, time, status, the cab (model and number)
/// and driver with their phone, or an Assign button while it has neither.
class _RideTile extends ConsumerWidget {
  const _RideTile(this.trip);
  final Trip trip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = context.fmt;
    final t = trip;
    final v = t.vehicle;
    final phone = (ref.watch(driversProvider).value ?? const [])
        .where((d) => d.id == t.driverId)
        .firstOrNull
        ?.phone;
    final canAssign =
        (v == null || t.driverId == null) &&
        t.allowedCommands.contains('assign');
    const muted = TextStyle(color: TaxcyColors.muted);
    Widget line(IconData icon, String text, {Key? key}) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: TaxcyColors.muted),
          const SizedBox(width: 6),
          Expanded(child: Text(text, key: key)),
        ],
      ),
    );
    return Card(
      key: ValueKey('ride-${t.id}'),
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: TaxcyColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () =>
            openScreen<void>(context, OwnerTripDetailScreen(tripId: t.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _route(l, t),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusChip(t.status),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                [
                  '${fmt.time(t.scheduledStartAt)} – '
                      '${fmt.time(t.scheduledEndAt)}',
                  ?t.customerName,
                ].join(' · '),
                style: muted,
              ),
              line(
                Icons.local_taxi_outlined,
                v == null
                    ? l.unassigned
                    : [
                        if (v.model.isNotEmpty) v.model,
                        formatRegistration(v.registrationNo),
                      ].join(' · '),
                key: ValueKey('ride-vehicle-${t.id}'),
              ),
              if (t.driverName != null)
                line(
                  Icons.person_outline,
                  [
                    t.driverName!,
                    if (phone != null) formatPhone(phone),
                  ].join(' · '),
                  key: ValueKey('ride-driver-${t.id}'),
                ),
              if (canAssign)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FilledButton.icon(
                      key: ValueKey('ride-assign-${t.id}'),
                      icon: const Icon(Icons.person_add_alt),
                      label: Text(l.assign),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => AssignDialog(trip: t),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Tag Driver": pick a trip still waiting for a cab and driver, then assign
/// one with the usual dialog.
Future<void> showTagDriver(BuildContext context) async {
  final picked = isDesktop(context)
      ? showDialog<Trip>(
          context: context,
          builder: (_) => const Dialog(
            child: SizedBox(width: 480, child: _TagDriverPicker()),
          ),
        )
      : showModalBottomSheet<Trip>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => const _TagDriverPicker(),
        );
  final trip = await picked;
  if (trip == null || !context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (_) => AssignDialog(trip: trip),
  );
}

class _TagDriverPicker extends ConsumerWidget {
  const _TagDriverPicker();

  static const _waiting = TripFilter(status: 'created');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = context.fmt;
    final trips = ref.watch(ownerTripsProvider(_waiting));
    return Padding(
      key: const Key('tag-driver'),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.pickTripToAssign,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Flexible(
            child: AsyncView(
              value: trips,
              onRetry: () => ref.invalidate(ownerTripsProvider(_waiting)),
              builder: (list) {
                if (list.isEmpty) return EmptyState(l.noTripsWaiting);
                final sorted = [...list]
                  ..sort(
                    (a, b) => a.scheduledStartAt.compareTo(b.scheduledStartAt),
                  );
                return ListView(
                  shrinkWrap: true,
                  children: [
                    for (final t in sorted)
                      ListTile(
                        key: ValueKey('tag-trip-${t.id}'),
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.route),
                        title: Text(_route(l, t)),
                        subtitle: Text(
                          [
                            fmt.dayTime(t.scheduledStartAt),
                            ?t.customerName,
                          ].join(' · '),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.of(context).pop(t),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// On the desktop dashboard the cards are see-through over the dot field;
/// the one under the pointer fades to solid and lifts a little, with a soft
/// shadow under it.
class _SolidOnHover extends StatefulWidget {
  const _SolidOnHover({required this.child});
  final Widget child;

  @override
  State<_SolidOnHover> createState() => _SolidOnHoverState();
}

class _SolidOnHoverState extends State<_SolidOnHover> {
  static const _duration = Duration(milliseconds: 150);
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
        child: Stack(
          // Keeps the row's stretch, so the headline cards stay equal height.
          fit: StackFit.passthrough,
          children: [
            // The shadow sits exactly under the card (inside its margin). It
            // is drawn here, not through the card theme, so cards nested in
            // this one don't each get a shadow too.
            Positioned.fill(
              child: Padding(
                padding: theme.cardTheme.margin ?? EdgeInsets.zero,
                child: AnimatedContainer(
                  duration: _duration,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: TaxcyColors.blue950.withValues(
                          alpha: _hovered ? 0.12 : 0,
                        ),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedTheme(
              duration: _duration,
              data: _hovered
                  ? theme.copyWith(
                      cardTheme: theme.cardTheme.copyWith(color: Colors.white),
                    )
                  : theme,
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}
