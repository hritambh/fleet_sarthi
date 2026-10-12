import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/format.dart';
import 'alerts_screen.dart';
import 'owner_providers.dart';
import 'owner_widgets.dart';
import 'review_screen.dart';

/// Alerts and the review queue in one place, as two tabs. Opened from the
/// [AlertsBell] in every owner page's header.
class AlertsInboxScreen extends ConsumerWidget {
  const AlertsInboxScreen({this.initialTab = 0, super.key});

  /// 0: alerts, 1: review.
  final int initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final summary = ref.watch(alertSummaryProvider).value;
    Tab tab(String label, int count, Key key) => Tab(
      key: key,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0) ...[
            const SizedBox(width: 6),
            Badge(label: Text(count > 99 ? '99+' : '$count')),
          ],
        ],
      ),
    );
    return DefaultTabController(
      length: 2,
      initialIndex: initialTab,
      child: Scaffold(
        key: const Key('alerts-inbox'),
        appBar: AppBar(
          title: Text(l.alertsInbox),
          bottom: TabBar(
            tabs: [
              tab(
                l.navAlerts,
                summary?.openAlerts ?? 0,
                const Key('tab-alerts'),
              ),
              tab(
                l.review,
                summary?.openReviewItems ?? 0,
                const Key('tab-review'),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AlertsScreen(embedded: true),
            ReviewScreen(embedded: true),
          ],
        ),
      ),
    );
  }
}

/// Opens the alerts and review inbox at [tab] (0: alerts, 1: review). On the
/// desktop it opens inside the current section, so the sidebar stays.
void openAlertsInbox(BuildContext context, [int tab = 0]) =>
    openScreen<void>(context, AlertsInboxScreen(initialTab: tab));

/// The bell in a page header: open alerts plus items to review as a badge.
class AlertsBell extends ConsumerWidget {
  const AlertsBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(alertSummaryProvider).value;
    final count = (summary?.openAlerts ?? 0) + (summary?.openReviewItems ?? 0);
    return IconButton(
      key: const Key('alerts-bell'),
      tooltip: context.l10n.alertsInbox,
      onPressed: () => openAlertsInbox(
        context,
        (summary?.openAlerts ?? 0) == 0 && (summary?.openReviewItems ?? 0) > 0
            ? 1
            : 0,
      ),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
