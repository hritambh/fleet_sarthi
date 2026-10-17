import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/owner_models.dart';
import '../common/format.dart';
import 'owner_providers.dart';
import 'owner_text.dart';
import 'alerts_inbox.dart';
import 'owner_widgets.dart';
import '../common/theme_picker.dart';

/// Each driver's settlement for one IST day (yesterday by default).
class SettlementsScreen extends ConsumerStatefulWidget {
  const SettlementsScreen({this.initialDate, super.key});
  final String? initialDate;

  @override
  ConsumerState<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends ConsumerState<SettlementsScreen> {
  late String _date = widget.initialDate ?? istDaysAgo(1);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final list = ref.watch(settlementsProvider(_date));
    return Scaffold(
      appBar: AppBar(
        title: Text(l.settlements),
        actions: const [ThemeToggleButton(), AlertsBell()],
      ),
      body: RefreshPage(
        onRefresh: () => ref.refresh(settlementsProvider(_date).future),
        children: [
          Text(
            l.settlementsIntro,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const Key('settlement-day'),
              icon: const Icon(Icons.calendar_today, size: 18),
              label: Text(fmt.calendarDate(_date)),
              onPressed: () async {
                final picked = await pickIsoDate(
                  context,
                  value: _date,
                  last: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
          ),
          const SizedBox(height: 8),
          AsyncView(
            value: list,
            onRetry: () => ref.invalidate(settlementsProvider(_date)),
            builder: (rows) => rows.isEmpty
                ? EmptyState(l.noActivity(date: fmt.calendarDate(_date)))
                : isDesktop(context)
                ? _SettlementTable(rows)
                : Column(children: [for (final s in rows) _SettlementTile(s)]),
          ),
        ],
      ),
    );
  }
}

/// The day's settlements on the desktop: one row per driver with trips,
/// money in and the balance; a click opens the driver's day.
class _SettlementTable extends StatelessWidget {
  const _SettlementTable(this.rows);
  final List<SettlementSummary> rows;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    return DesktopTable(
      key: const Key('settlement-table'),
      columns: [
        TableColumn(l.driver, flex: 3),
        TableColumn(l.navTrips, end: true),
        TableColumn(l.expected, end: true),
        TableColumn(l.methodCash, end: true),
        TableColumn(l.online, end: true),
        TableColumn(l.colBalance, flex: 4),
        TableColumn(l.colShortfall, end: true),
        TableColumn(l.status),
      ],
      rows: [
        for (final s in rows)
          TableRowData(
            key: ValueKey('settlement-${s.driverId}'),
            onTap: () => openScreen<void>(
              context,
              SettlementDetailScreen(
                date: s.businessDate,
                driverId: s.driverId,
              ),
            ),
            cells: [
              Row(
                children: [
                  InitialsAvatar(s.driverName, radius: 16),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      s.driverName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              Text(fmt.number(s.tripCount)),
              Text(fmt.inr(s.expectedFarePaise)),
              Text(fmt.inr(s.cashPaise)),
              Text(fmt.inr(s.onlinePaise)),
              Text(
                netPayableText(fmt, s.netPayablePaise),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: s.netPayablePaise < 0
                      ? context.adaptive(Colors.amber.shade900, TaxcyDark.warn)
                      : context.tc.ink,
                ),
              ),
              Text(
                s.shortfallPaise == 0 ? '–' : fmt.inr(s.shortfallPaise),
                style: TextStyle(
                  color: s.shortfallPaise == 0
                      ? context.tc.muted
                      : context.adaptive(Colors.red.shade700, TaxcyDark.bad),
                  fontWeight: s.shortfallPaise == 0
                      ? FontWeight.w400
                      : FontWeight.w600,
                ),
              ),
              ToneChip(
                s.isSettled ? l.statusSettled : l.draft,
                tone: s.isSettled ? Tone.success : Tone.warning,
              ),
            ],
          ),
      ],
    );
  }
}

class _SettlementTile extends StatelessWidget {
  const _SettlementTile(this.s);
  final SettlementSummary s;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    return Card(
      child: ListTile(
        key: ValueKey('settlement-${s.driverId}'),
        title: Text(
          s.driverName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l.tripsCount(count: s.tripCount)} · '
              '${l.expected} ${fmt.inr(s.expectedFarePaise)} · '
              '${l.methodCash} ${fmt.inr(s.cashPaise)}',
            ),
            Text(
              netPayableText(fmt, s.netPayablePaise),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: s.netPayablePaise < 0
                    ? context.adaptive(Colors.amber.shade900, TaxcyDark.warn)
                    : context.tc.ink,
              ),
            ),
            if (s.shortfallPaise != 0)
              Text(
                l.shortfall(amount: fmt.inr(s.shortfallPaise)),
                style: TextStyle(
                  color: context.adaptive(Colors.red.shade700, TaxcyDark.bad),
                ),
              ),
          ],
        ),
        trailing: ToneChip(
          s.isSettled ? l.statusSettled : l.draft,
          tone: s.isSettled ? Tone.success : Tone.warning,
        ),
        onTap: () => openScreen<void>(
          context,
          SettlementDetailScreen(date: s.businessDate, driverId: s.driverId),
        ),
      ),
    );
  }
}

/// A driver's day: totals, every line it covers, and "Mark settled".
class SettlementDetailScreen extends ConsumerStatefulWidget {
  const SettlementDetailScreen({
    required this.date,
    required this.driverId,
    super.key,
  });

  final String date;
  final String driverId;

  @override
  ConsumerState<SettlementDetailScreen> createState() =>
      _SettlementDetailScreenState();
}

class _SettlementDetailScreenState
    extends ConsumerState<SettlementDetailScreen> {
  // Kept for the screen's life, so retrying a failed settle can't settle twice.
  final _idempotencyKey = const Uuid().v4();
  bool _busy = false;

  ({String date, String driverId}) get _key =>
      (date: widget.date, driverId: widget.driverId);

  Future<void> _settle() async {
    setState(() => _busy = true);
    await runAction(context, () async {
      await ref
          .read(ownerApiProvider)
          .settle(
            widget.date,
            widget.driverId,
            idempotencyKey: _idempotencyKey,
          );
      refreshAfter(ref, {OwnerArea.settlements, OwnerArea.trips});
    });
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final detail = ref.watch(settlementProvider(_key));
    final name = detail.value?.summary.driverName;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          name == null
              ? l.settlementLabel
              : '$name · ${fmt.calendarDate(widget.date)}',
        ),
      ),
      body: AsyncView(
        value: detail,
        onRetry: () => ref.invalidate(settlementProvider(_key)),
        builder: (d) {
          final s = d.summary;
          return RefreshPage(
            onRefresh: () => ref.refresh(settlementProvider(_key).future),
            children: [
              SectionCard(
                child: StatGrid([
                  StatTile(
                    label: l.expectedFare,
                    value: fmt.inr(s.expectedFarePaise),
                  ),
                  StatTile(label: l.cashCollected, value: fmt.inr(s.cashPaise)),
                  StatTile(label: l.onlineToYou, value: fmt.inr(s.onlinePaise)),
                  StatTile(
                    label: l.driversExpenses,
                    value: fmt.inr(s.driverExpensesPaise),
                  ),
                  StatTile(
                    label: l.driversEarnings,
                    value: fmt.inr(s.driverEarningsPaise),
                    hint: payRuleText(fmt, d.payRule),
                  ),
                  StatTile(
                    label: l.lateItems,
                    value: s.carriedAdjustmentPaise == 0
                        ? l.noValue
                        : fmt.inr(s.carriedAdjustmentPaise),
                  ),
                  StatTile(
                    label: l.shortfallLabel,
                    value: fmt.inr(s.shortfallPaise),
                    hint: l.shortfallHint,
                  ),
                  StatTile(
                    key: const Key('net-payable'),
                    label: l.settlementLabel,
                    value: netPayableText(fmt, s.netPayablePaise),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  l.netFormula,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              SectionCard(
                child: Column(
                  children: [
                    for (final line in d.lines)
                      ListTile(
                        key: ValueKey('line-${line.refType}-${line.refId}'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: SizedBox(
                          width: 72,
                          child: Text(
                            settlementLineLabel(l, line.refType),
                            style: TextStyle(color: context.tc.muted),
                          ),
                        ),
                        title: Text(settlementLineText(fmt, line)),
                        subtitle: line.originalDate == null
                            ? null
                            : Text(
                                l.lateFrom(
                                  date: fmt.calendarDate(line.originalDate!),
                                ),
                                style: TextStyle(
                                  color: context.adaptive(
                                    Colors.amber.shade900,
                                    TaxcyDark.warn,
                                  ),
                                ),
                              ),
                        trailing: Text(fmt.inr(line.amountPaise)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (s.isSettled)
                Text(
                  l.settledOn(
                    when: s.settledAt == null
                        ? l.noValue
                        : fmt.dayTime(s.settledAt!),
                  ),
                  key: const Key('settled-note'),
                )
              else ...[
                Text(l.markSettledHint),
                const SizedBox(height: 8),
                FilledButton.icon(
                  key: const Key('mark-settled'),
                  icon: const Icon(Icons.lock_outline),
                  onPressed: _busy || d.lines.isEmpty ? null : _settle,
                  label: Text(l.markSettled),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
