import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/owner_api.dart';
import '../../core/api/owner_models.dart';
import '../common/format.dart';
import '../common/magnetic_field_background.dart';
import 'alerts_inbox.dart';
import 'alerts_screen.dart';
import 'documents_screen.dart';
import 'owner_providers.dart';
import 'owner_text.dart';
import 'owner_widgets.dart';
import 'people_screens.dart';
import 'trips/create_trip_screen.dart';
import 'trips/owner_trips_screen.dart';
import 'vehicles_screen.dart';

const _severityOrder = {'critical': 0, 'warning': 1, 'info': 2};

enum _Day { today, yesterday, custom }

/// A day at a glance: headline cards (cabs and drivers free right now, the
/// unassigned queue, completed trips and gross fare), that day's trips, what
/// needs attention, documents due and the most urgent open alerts. The date
/// switch picks the day. On a desktop-sized screen: a greeting and two columns.
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

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const _openAlerts = (status: 'open', kind: null, tripId: null);
  static const _dueDocuments = DocumentsDueChip.dueQuery;

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
    final summary = ref.watch(alertSummaryProvider);
    final headline = ref.watch(dashboardSummaryProvider(date));
    final alerts = ref.watch(alertsProvider(_openAlerts));
    final documents = ref.watch(documentsProvider(_dueDocuments));
    final desktop = isDesktop(context);
    // Count tiles share a row evenly on the desktop; on phones they wrap.
    Widget tiles(List<Widget> children) => desktop
        ? Row(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: children[i]),
              ],
            ],
          )
        : Wrap(spacing: 8, runSpacing: 8, children: children);

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

    final cards = AsyncView(
      value: headline,
      onRetry: () => ref.invalidate(dashboardSummaryProvider(date)),
      builder: (s) => _HeadlineCards(s, onOpenTrips: widget.onOpenTrips),
    );

    final todaysTrips = SectionCard(
      title: _day == _Day.today
          ? l.todaysTrips
          : l.tripsOnDay(date: fmt.calendarDate(date)),
      actions: [
        TextButton(onPressed: widget.onOpenTrips, child: Text(l.seeAll)),
      ],
      child: AsyncView(
        value: trips,
        onRetry: () => ref.invalidate(ownerTripsProvider(filter)),
        builder: (list) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            tiles([
              for (final s in tripStatuses)
                _CountTile(
                  key: ValueKey('today-$s'),
                  count: list.where((t) => t.status == s).length,
                  label: statusLabel(l, s),
                  width: desktop ? null : 104,
                ),
            ]),
            const SizedBox(height: 8),
            if (list.isEmpty)
              EmptyState(l.noTripsToday)
            else
              for (final t
                  in [...list]..sort(
                    (a, b) => a.scheduledStartAt.compareTo(b.scheduledStartAt),
                  ))
                OwnerTripTile(t),
          ],
        ),
      ),
    );
    final attention = SectionCard(
      title: l.needsAttention,
      child: AsyncView(
        value: summary,
        onRetry: () => ref.invalidate(alertSummaryProvider),
        builder: (s) => tiles([
          _CountTile(
            key: const Key('critical-count'),
            count: s.critical,
            label: l.criticalAlerts,
            color: Colors.red.shade700,
            onTap: () => openAlertsInbox(context),
            width: desktop ? null : 104,
          ),
          _CountTile(
            count: s.warning,
            label: l.severityWarning,
            color: Colors.amber.shade900,
            onTap: () => openAlertsInbox(context),
            width: desktop ? null : 104,
          ),
          _CountTile(
            count: s.info,
            label: l.severityInfo,
            onTap: () => openAlertsInbox(context),
            width: desktop ? null : 104,
          ),
          _CountTile(
            key: const Key('review-count'),
            count: s.openReviewItems,
            label: l.toReview,
            onTap: () => openAlertsInbox(context, 1),
            width: desktop ? null : 104,
          ),
        ]),
      ),
    );
    final documentsDue = SectionCard(
      title: l.documentsDueSoon,
      child: AsyncView(
        value: documents,
        onRetry: () => ref.invalidate(documentsProvider(_dueDocuments)),
        builder: (docs) {
          final soon = docs
              .where((d) => d.status == 'expiring' || d.status == 'expired')
              .take(6)
              .toList();
          if (soon.isEmpty) return EmptyState(l.nothingExpiring);
          return Column(
            children: [
              for (final d in soon)
                ListTile(
                  key: ValueKey('due-${d.id}'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(docTypeLabel(l, d.docType)),
                  subtitle: Text(fmt.calendarDate(d.expiresOn)),
                  trailing: DocumentStatusChip(d),
                  onTap: () => openDocumentOwner(
                    context,
                    vehicleId: d.vehicleId,
                    driverId: d.driverId,
                  ),
                ),
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
        ..invalidate(alertSummaryProvider)
        ..invalidate(dashboardSummaryProvider(date))
        ..invalidate(alertsProvider(_openAlerts))
        ..invalidate(documentsProvider(_dueDocuments))
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
            todaysTrips,
            attention,
            documentsDue,
            openAlerts,
          ],
        ),
      );
    }

    final session = ref.watch(authProvider).value;
    final firstName = (session?.name ?? '').trim().split(' ').first;
    return Scaffold(
      appBar: appBar,
      // A quiet field of dashes behind the cards that turns towards the
      // pointer (desktop only; still when reduced motion is on).
      body: MagneticFieldBackground(
        accentColor: TaxcyColors.blue600,
        child: RefreshPage(
          onRefresh: refresh,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
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
                  FilledButton.icon(
                    key: const Key('dashboard-new-trip'),
                    onPressed: () =>
                        openScreen<void>(context, const CreateTripScreen()),
                    icon: const Icon(Icons.add),
                    label: Text(l.newTrip),
                  ),
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
                  child: Column(children: [todaysTrips, openAlerts]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(children: [attention, documentsDue]),
                ),
              ],
            ),
          ],
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
  const _HeadlineCards(this.s, {required this.onOpenTrips});
  final DashboardSummary s;
  final VoidCallback onOpenTrips;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    double? share(int part, int total) => total == 0 ? null : part / total;
    final change = s.completedChangePercent;
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
            Expanded(child: card),
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

class _CountTile extends StatelessWidget {
  const _CountTile({
    required this.count,
    required this.label,
    this.color,
    this.onTap,
    this.width,
    super.key,
  });

  final int count;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  /// Fixed on phones (tiles wrap); null fills a desktop row's share.
  final double? width;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: TaxcyColors.blue50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TaxcyColors.blue100),
      ),
      child: Column(
        children: [
          Text(
            context.fmt.number(count),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: color ?? TaxcyColors.blue800,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(fontSize: 12, color: TaxcyColors.muted),
          ),
        ],
      ),
    ),
  );
}
