import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/owner_api.dart';
import '../../core/api/owner_models.dart';
import '../common/format.dart';
import '../common/magnetic_field_background.dart';
import 'alerts_screen.dart';
import 'documents_screen.dart';
import 'owner_providers.dart';
import 'owner_text.dart';
import 'owner_widgets.dart';
import 'review_screen.dart';
import 'trips/create_trip_screen.dart';
import 'trips/owner_trips_screen.dart';

const _severityOrder = {'critical': 0, 'warning': 1, 'info': 2};

/// Today at a glance: trips by status, what needs attention, documents due, and
/// the most urgent open alerts. [onOpenTab] switches the owner shell's tab.
/// On a desktop-sized screen: a greeting, headline numbers and two columns.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    required this.onOpenTab,
    this.onOpenReview,
    super.key,
  });
  final ValueChanged<int> onOpenTab;

  /// Opens the review queue (the desktop sidebar's section); without it, the
  /// review screen is pushed.
  final VoidCallback? onOpenReview;

  static TripFilter todayFilter([DateTime? now]) {
    final (from, to) = istDayRange(istToday(now));
    return TripFilter(from: from, to: to);
  }

  static const _openAlerts = (status: 'open', kind: null, tripId: null);
  static const _dueDocuments = (
    vehicleId: null,
    driverId: null,
    expiringWithinDays: 30,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = context.fmt;
    final filter = todayFilter();
    final trips = ref.watch(ownerTripsProvider(filter));
    final summary = ref.watch(alertSummaryProvider);
    final alerts = ref.watch(alertsProvider(_openAlerts));
    final documents = ref.watch(documentsProvider(_dueDocuments));
    final desktop = isDesktop(context);
    void openReview() => onOpenReview != null
        ? onOpenReview!()
        : openScreen<void>(context, const ReviewScreen());
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
    List<FleetDocument> due(List<FleetDocument> docs) => docs
        .where((d) => d.status == 'expiring' || d.status == 'expired')
        .toList();

    final todaysTrips = SectionCard(
      title: l.todaysTrips,
      actions: [
        TextButton(onPressed: () => onOpenTab(1), child: Text(l.seeAll)),
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
            onTap: () => onOpenTab(2),
            width: desktop ? null : 104,
          ),
          _CountTile(
            count: s.warning,
            label: l.severityWarning,
            color: Colors.amber.shade900,
            onTap: () => onOpenTab(2),
            width: desktop ? null : 104,
          ),
          _CountTile(
            count: s.info,
            label: l.severityInfo,
            onTap: () => onOpenTab(2),
            width: desktop ? null : 104,
          ),
          _CountTile(
            key: const Key('review-count'),
            count: s.openReviewItems,
            label: l.toReview,
            onTap: openReview,
            width: desktop ? null : 104,
          ),
        ]),
      ),
    );
    final documentsDue = SectionCard(
      title: l.documentsDueSoon,
      actions: [
        TextButton(
          onPressed: () => openScreen<void>(context, const DocumentsScreen()),
          child: Text(l.seeAll),
        ),
      ],
      child: AsyncView(
        value: documents,
        onRetry: () => ref.invalidate(documentsProvider(_dueDocuments)),
        builder: (docs) {
          final soon = due(docs).take(6).toList();
          if (soon.isEmpty) return EmptyState(l.nothingExpiring);
          return Column(
            children: [
              for (final d in soon)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(docTypeLabel(l, d.docType)),
                  subtitle: Text(fmt.calendarDate(d.expiresOn)),
                  trailing: DocumentStatusChip(d),
                ),
            ],
          );
        },
      ),
    );
    final openAlerts = SectionCard(
      title: l.openAlerts,
      actions: [
        TextButton(onPressed: () => onOpenTab(2), child: Text(l.seeAll)),
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
        ..invalidate(alertsProvider(_openAlerts))
        ..invalidate(documentsProvider(_dueDocuments))
        ..invalidate(ownerTripsProvider(filter));
      await ref.read(ownerTripsProvider(filter).future);
    }

    if (!desktop) {
      return Scaffold(
        appBar: AppBar(title: Text(l.navDashboard)),
        body: RefreshPage(
          onRefresh: refresh,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${l.today} · ${fmt.calendarDate(istToday())}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
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
    final tripList = trips.value ?? const [];
    final s = summary.value;
    final dueCount = documents.value == null
        ? null
        : due(documents.value!).length;
    return Scaffold(
      appBar: AppBar(title: Text(l.navDashboard)),
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
                          '${l.today} · ${fmt.calendarDate(istToday())}'
                          ' · ${session?.activeMembership?.orgName ?? ''}',
                          style: const TextStyle(color: TaxcyColors.muted),
                        ),
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
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: MetricCard(
                      icon: Icons.route,
                      accent: TaxcyColors.blue600,
                      label: l.todaysTrips,
                      value: trips.hasValue ? fmt.number(tripList.length) : '–',
                      hint:
                          '${statusLabel(l, 'started')}: '
                          '${fmt.number(tripList.where((t) => t.status == 'started').length)}',
                      onTap: () => onOpenTab(1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MetricCard(
                      icon: Icons.notifications_active_outlined,
                      accent: Colors.red.shade600,
                      label: l.openAlerts,
                      value: s == null ? '–' : fmt.number(s.openAlerts),
                      hint: s == null
                          ? null
                          : '${l.criticalAlerts}: ${fmt.number(s.critical)}',
                      onTap: () => onOpenTab(2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MetricCard(
                      icon: Icons.fact_check_outlined,
                      accent: Colors.amber.shade800,
                      label: l.toReview,
                      value: s == null ? '–' : fmt.number(s.openReviewItems),
                      onTap: openReview,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: MetricCard(
                      icon: Icons.event_busy_outlined,
                      accent: Colors.teal.shade600,
                      label: l.documentsDueSoon,
                      value: dueCount == null ? '–' : fmt.number(dueCount),
                      onTap: () =>
                          openScreen<void>(context, const DocumentsScreen()),
                    ),
                  ),
                ],
              ),
            ),
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
