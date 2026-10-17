import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/owner_models.dart';
import '../common/format.dart';
import 'people_screens.dart';
import 'fuel_screens.dart';
import 'owner_providers.dart';
import 'owner_text.dart';
import 'owner_widgets.dart';
import 'trips/owner_trip_detail_screen.dart';
import 'vehicles_screen.dart';

/// The alerts inbox, filtered by status and kind.
class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({this.embedded = false, super.key});

  /// Inside [AlertsInboxScreen]'s tabs: no page header of its own.
  final bool embedded;

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  var _filters = const AlertFilters(statuses: {'open'});

  AlertQuery get _query => alertQuery(
    statuses: _filters.statuses,
    kinds: _filters.kinds,
    severities: _filters.severities,
    vehicleIds: _filters.vehicleIds,
    driverIds: _filters.driverIds,
  );

  Future<void> _edit() async {
    final picked = await showAlertFilters(context, _filters);
    if (picked != null) setState(() => _filters = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final alerts = ref.watch(alertsProvider(_query));
    final vehicles = ref.watch(fleetVehiclesProvider).value ?? const [];
    final drivers = ref.watch(driversProvider).value ?? const [];
    String vehicleName(String id) =>
        vehicles
            .where((v) => v.id == id)
            .map((v) => formatRegistration(v.registrationNo))
            .firstOrNull ??
        l.vehicle;
    String driverName(String id) =>
        drivers.where((d) => d.id == id).map((d) => d.name).firstOrNull ??
        l.driver;
    final f = _filters;
    // Each applied filter as a removable chip.
    final chips = [
      for (final s in f.statuses)
        (
          'status-$s',
          alertStatusLabel(l, s),
          () => f.copyWith(statuses: {...f.statuses}..remove(s)),
        ),
      for (final k in f.kinds)
        (
          'kind-$k',
          alertKindLabel(l, k),
          () => f.copyWith(kinds: {...f.kinds}..remove(k)),
        ),
      for (final s in f.severities)
        (
          'severity-$s',
          severityLabel(l, s),
          () => f.copyWith(severities: {...f.severities}..remove(s)),
        ),
      for (final id in f.vehicleIds)
        (
          'vehicle-$id',
          vehicleName(id),
          () => f.copyWith(vehicleIds: {...f.vehicleIds}..remove(id)),
        ),
      for (final id in f.driverIds)
        (
          'driver-$id',
          driverName(id),
          () => f.copyWith(driverIds: {...f.driverIds}..remove(id)),
        ),
    ];
    final body = RefreshPage(
      onRefresh: () => ref.refresh(alertsProvider(_query).future),
      children: [
        Text(l.alertsIntro, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.tonalIcon(
              key: const Key('alert-filters'),
              onPressed: _edit,
              icon: const Icon(Icons.filter_list),
              label: Text(
                chips.isEmpty ? l.filters : l.filtersCount(count: chips.length),
              ),
            ),
            for (final (key, label, without) in chips)
              InputChip(
                key: ValueKey('filter-chip-$key'),
                label: Text(label),
                onDeleted: () => setState(() => _filters = without()),
              ),
            if (chips.isNotEmpty)
              TextButton(
                key: const Key('alert-filters-clear'),
                onPressed: () =>
                    setState(() => _filters = const AlertFilters()),
                child: Text(l.clearAll),
              ),
          ],
        ),
        const SizedBox(height: 8),
        AsyncView(
          value: alerts,
          onRetry: () => ref.invalidate(alertsProvider(_query)),
          builder: (list) => list.isEmpty
              ? EmptyState(
                  f == const AlertFilters(statuses: {'open'})
                      ? l.allClear
                      : l.noAlertsMatch,
                )
              : Column(children: [for (final a in list) AlertCard(a)]),
        ),
      ],
    );
    if (widget.embedded) return body;
    return Scaffold(
      appBar: AppBar(title: Text(l.navAlerts)),
      body: body,
    );
  }
}

/// The alerts list's filters; each set means "any of these", empty means all.
@immutable
class AlertFilters {
  const AlertFilters({
    this.statuses = const {},
    this.kinds = const {},
    this.severities = const {},
    this.vehicleIds = const {},
    this.driverIds = const {},
  });

  final Set<String> statuses;
  final Set<String> kinds;
  final Set<String> severities;
  final Set<String> vehicleIds;
  final Set<String> driverIds;

  AlertFilters copyWith({
    Set<String>? statuses,
    Set<String>? kinds,
    Set<String>? severities,
    Set<String>? vehicleIds,
    Set<String>? driverIds,
  }) => AlertFilters(
    statuses: statuses ?? this.statuses,
    kinds: kinds ?? this.kinds,
    severities: severities ?? this.severities,
    vehicleIds: vehicleIds ?? this.vehicleIds,
    driverIds: driverIds ?? this.driverIds,
  );

  static bool _same(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  @override
  bool operator ==(Object other) =>
      other is AlertFilters &&
      _same(statuses, other.statuses) &&
      _same(kinds, other.kinds) &&
      _same(severities, other.severities) &&
      _same(vehicleIds, other.vehicleIds) &&
      _same(driverIds, other.driverIds);

  @override
  int get hashCode => Object.hash(
    statuses.length,
    kinds.length,
    severities.length,
    vehicleIds.length,
    driverIds.length,
  );
}

/// Opens the filter picker (a sheet on phones, a dialog on the desktop) and
/// returns the new filters, or null when cancelled.
Future<AlertFilters?> showAlertFilters(
  BuildContext context,
  AlertFilters current,
) {
  final sheet = _AlertFilterSheet(initial: current);
  if (isDesktop(context)) {
    return showDialog<AlertFilters>(
      context: context,
      builder: (_) =>
          Dialog(child: SizedBox(width: 560, height: 640, child: sheet)),
    );
  }
  return showModalBottomSheet<AlertFilters>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => FractionallySizedBox(heightFactor: 0.85, child: sheet),
  );
}

class _AlertFilterSheet extends ConsumerStatefulWidget {
  const _AlertFilterSheet({required this.initial});
  final AlertFilters initial;

  @override
  ConsumerState<_AlertFilterSheet> createState() => _AlertFilterSheetState();
}

class _AlertFilterSheetState extends ConsumerState<_AlertFilterSheet> {
  late final _statuses = {...widget.initial.statuses};
  late final _kinds = {...widget.initial.kinds};
  late final _severities = {...widget.initial.severities};
  late final _vehicles = {...widget.initial.vehicleIds};
  late final _drivers = {...widget.initial.driverIds};

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final vehicles = ref.watch(fleetVehiclesProvider).value ?? const [];
    final drivers = ref.watch(driversProvider).value ?? const [];
    Widget group(
      String key,
      String title,
      Set<String> chosen,
      List<(String, String)> options,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (value, label) in options)
                FilterChip(
                  key: ValueKey('filter-$key-$value'),
                  label: Text(label),
                  selected: chosen.contains(value),
                  onSelected: (on) => setState(
                    () => on ? chosen.add(value) : chosen.remove(value),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.filters,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              TextButton(
                key: const Key('alert-filters-reset'),
                onPressed: () => setState(() {
                  for (final s in [
                    _statuses,
                    _kinds,
                    _severities,
                    _vehicles,
                    _drivers,
                  ]) {
                    s.clear();
                  }
                }),
                child: Text(l.clearAll),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              group('status', l.status, _statuses, [
                for (final s in const [
                  'open',
                  'acknowledged',
                  'resolved',
                  'dismissed',
                ])
                  (s, alertStatusLabel(l, s)),
              ]),
              group('severity', l.severity, _severities, [
                for (final s in const ['critical', 'warning', 'info'])
                  (s, severityLabel(l, s)),
              ]),
              group('kind', l.alertKindTitle, _kinds, [
                for (final k in Alert.kinds) (k, alertKindLabel(l, k)),
              ]),
              group('vehicle', l.vehicles, _vehicles, [
                for (final v in vehicles)
                  (v.id, formatRegistration(v.registrationNo)),
              ]),
              group('driver', l.drivers, _drivers, [
                for (final d in drivers) (d.id, d.name),
              ]),
              const SizedBox(height: 12),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const Key('alert-filters-apply'),
                onPressed: () => Navigator.of(context).pop(
                  AlertFilters(
                    statuses: _statuses,
                    kinds: _kinds,
                    severities: _severities,
                    vehicleIds: _vehicles,
                    driverIds: _drivers,
                  ),
                ),
                child: Text(l.apply),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One alert, worded from its message code, with its actions.
class AlertCard extends ConsumerWidget {
  const AlertCard(this.alert, {this.compact = false, super.key});
  final Alert alert;

  /// The dashboard shows alerts without actions.
  final bool compact;

  Future<void> _update(
    BuildContext context,
    WidgetRef ref,
    String status, {
    bool? falsePositive,
  }) => runAction(context, () async {
    await ref
        .read(ownerApiProvider)
        .updateAlert(alert.id, status, falsePositive: falsePositive);
    refreshAfter(ref, {OwnerArea.alerts, OwnerArea.fuel});
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = context.fmt;
    final a = alert;
    final link = _subjectLink(context);
    final desktop = isDesktop(context);
    final accent = switch (a.severity) {
      'critical' => context.adaptive(Colors.red.shade600, TaxcyDark.bad),
      'warning' => context.adaptive(Colors.amber.shade700, TaxcyDark.warn),
      _ => context.tc.blue600,
    };
    // Full width, so short alerts don't shrink to their text.
    return SizedBox(
      width: double.infinity,
      child: Card(
        key: ValueKey('alert-${a.id}'),
        clipBehavior: Clip.antiAlias,
        child: Container(
          // On the desktop, the severity colours the card's left edge.
          decoration: desktop
              ? BoxDecoration(
                  border: Border(left: BorderSide(color: accent, width: 4)),
                )
              : null,
          padding: EdgeInsets.all(desktop ? 18 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SeverityChip(a.severity),
                  ToneChip(alertKindLabel(l, a.kind)),
                  if (a.status != 'open')
                    ToneChip(alertStatusLabel(l, a.status)),
                  if (a.falsePositive) ToneChip(l.falseAlarm, tone: Tone.brand),
                  Text(
                    fmt.dayTime(a.createdAt),
                    style: TextStyle(fontSize: 12, color: context.tc.muted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                alertTitle(fmt, a),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                alertBody(fmt, a),
                maxLines: compact ? 3 : null,
                overflow: compact ? TextOverflow.ellipsis : null,
              ),
              if (!compact) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (link != null)
                      TextButton(onPressed: link.$2, child: Text(link.$1)),
                    if (a.status == 'open')
                      TextButton(
                        key: const Key('alert-acknowledge'),
                        onPressed: () => _update(context, ref, 'acknowledged'),
                        child: Text(l.acknowledge),
                      ),
                    if (a.isOpen && a.isFuel)
                      OutlinedButton(
                        key: const Key('alert-false-alarm'),
                        onPressed: () => _update(
                          context,
                          ref,
                          'dismissed',
                          falsePositive: true,
                        ),
                        child: Text(l.dismissFalseAlarm),
                      ),
                    if (a.isOpen)
                      OutlinedButton(
                        key: const Key('alert-dismiss'),
                        onPressed: () => _update(context, ref, 'dismissed'),
                        child: Text(l.dismiss),
                      ),
                    if (a.isOpen)
                      FilledButton(
                        key: const Key('alert-resolve'),
                        onPressed: () => _update(context, ref, 'resolved'),
                        child: Text(l.markResolved),
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

  (String, VoidCallback)? _subjectLink(BuildContext context) {
    final l = context.l10n;
    final a = alert;
    if (a.isFuel && a.vehicleId != null) {
      return (
        l.openFuelHistory,
        () => fire(
          openScreen(context, VehicleFuelScreen(vehicleId: a.vehicleId!)),
        ),
      );
    }
    if (a.tripId != null) {
      return (
        l.openTrip,
        () =>
            fire(openScreen(context, OwnerTripDetailScreen(tripId: a.tripId!))),
      );
    }
    if (a.subjectType == 'document' &&
        (a.vehicleId != null || a.driverId != null)) {
      return (
        l.openDocuments,
        () => openDocumentOwner(
          context,
          vehicleId: a.vehicleId,
          driverId: a.driverId,
        ),
      );
    }
    if (a.vehicleId != null) {
      return (
        l.openVehicle,
        () => fire(
          openScreen(context, VehicleDetailScreen(vehicleId: a.vehicleId!)),
        ),
      );
    }
    return null;
  }
}
