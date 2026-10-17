import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/api.dart';
import '../../core/api/models.dart';
import '../../core/api/owner_models.dart';
import '../common/format.dart';
import '../driver/driver_profile_form.dart';
import 'documents_screen.dart';
import 'links.dart';
import 'owner_providers.dart';
import 'owner_text.dart';
import 'alerts_inbox.dart';
import 'owner_widgets.dart';
import 'pay_rule_editor.dart';
import 'trip_schedule.dart';
import 'vehicles_screen.dart';
import '../common/theme_picker.dart';

/// The fleet's drivers with their pay; invite by phone.
class DriversScreen extends ConsumerWidget {
  const DriversScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = context.fmt;
    final drivers = ref.watch(driversProvider);
    final defaultRule = ref.watch(defaultPayRuleProvider).value;
    final action = PageAction(
      key: const Key('invite-driver'),
      icon: Icons.person_add,
      label: l.inviteDriver,
      onPressed: () => _invite(context, ref, manager: false),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(l.drivers),
        actions: [
          const ThemeToggleButton(),
          const AlertsBell(),
          ...action.headerActions(context),
        ],
      ),
      floatingActionButton: action.fab(context),
      body: RefreshPage(
        onRefresh: () => ref.refresh(driversProvider.future),
        children: [
          AsyncView(
            value: drivers,
            onRetry: () => ref.invalidate(driversProvider),
            builder: (list) => list.isEmpty
                ? EmptyState(l.noDriversYet)
                : isDesktop(context)
                ? CardGrid(
                    children: [
                      for (final d in list)
                        _DriverCard(driver: d, defaultRule: defaultRule),
                    ],
                  )
                : Column(
                    children: [
                      for (final d in list)
                        Card(
                          key: ValueKey('driver-card-${d.id}'),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: d.isActive
                              ? null
                              : context.adaptive(
                                  Colors.red.shade50,
                                  TaxcyDark.badBg,
                                ),
                          shape: d.isActive
                              ? null
                              : RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: context.adaptive(
                                      Colors.red.shade300,
                                      TaxcyDark.badBorder,
                                    ),
                                  ),
                                ),
                          child: ListTile(
                            key: ValueKey('driver-${d.id}'),
                            leading: InitialsAvatar(
                              d.name,
                              photoMediaId: d.photoMediaId,
                            ),
                            title: Text(
                              d.name,
                              style: d.isActive
                                  ? null
                                  : TextStyle(
                                      color: context.adaptive(
                                        Colors.red.shade800,
                                        TaxcyDark.bad,
                                      ),
                                    ),
                            ),
                            subtitle: Text(
                              [
                                formatPhone(d.phone),
                                if (d.payRule != null)
                                  payRuleText(fmt, d.payRule!)
                                else if (defaultRule != null)
                                  l.payDefault(
                                    rule: payRuleText(fmt, defaultRule),
                                  ),
                              ].join(' · '),
                            ),
                            trailing: Wrap(
                              spacing: 4,
                              direction: Axis.vertical,
                              crossAxisAlignment: WrapCrossAlignment.end,
                              children: [
                                ToneChip(
                                  d.isActive ? l.active : l.inactive,
                                  tone: d.isActive ? Tone.success : Tone.danger,
                                ),
                                if (d.membershipStatus == 'invited')
                                  ToneChip(l.notSignedInYet, tone: Tone.brand),
                                DocumentsDueChip(driverId: d.id),
                              ],
                            ),
                            onTap: () => openScreen<void>(
                              context,
                              DriverScreen(driver: d),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// A driver on the desktop: avatar, number, status, pay rule and the vehicles
/// they may drive.
class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.driver, required this.defaultRule});
  final Driver driver;
  final PayRule? defaultRule;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final d = driver;
    final pay = d.payRule != null
        ? payRuleText(fmt, d.payRule!)
        : defaultRule == null
        ? null
        : l.payDefault(rule: payRuleText(fmt, defaultRule!));
    final inactive = !d.isActive;
    return Card(
      key: ValueKey('driver-card-${d.id}'),
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: inactive
          ? context.adaptive(Colors.red.shade50, TaxcyDark.badBg)
          : null,
      shape: inactive
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: context.adaptive(
                  Colors.red.shade300,
                  TaxcyDark.badBorder,
                ),
              ),
            )
          : null,
      child: InkWell(
        key: ValueKey('driver-${d.id}'),
        onTap: () => openScreen<void>(context, DriverScreen(driver: d)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InitialsAvatar(
                    d.name,
                    radius: 22,
                    photoMediaId: d.photoMediaId,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: inactive
                                    ? context.adaptive(
                                        Colors.red.shade800,
                                        TaxcyDark.bad,
                                      )
                                    : null,
                              ),
                        ),
                        Text(
                          formatPhone(d.phone),
                          style: TextStyle(color: context.tc.muted),
                        ),
                      ],
                    ),
                  ),
                  ToneChip(
                    d.isActive ? l.active : l.inactive,
                    tone: d.isActive ? Tone.success : Tone.danger,
                  ),
                ],
              ),
              if (d.membershipStatus == 'invited') ...[
                const SizedBox(height: 8),
                ToneChip(l.notSignedInYet, tone: Tone.brand),
              ],
              const SizedBox(height: 4),
              DocumentsDueChip(driverId: d.id),
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 12),
              if (pay != null)
                Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: context.tc.muted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pay,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final v in d.vehicles)
                    ToneChip(
                      formatRegistration(v.registrationNo),
                      tone: Tone.brand,
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

/// Invites a driver, or (owner only) a manager, by name and mobile number.
Future<void> _invite(
  BuildContext context,
  WidgetRef ref, {
  required bool manager,
}) => showDialog<void>(
  context: context,
  builder: (_) => InviteDialog(manager: manager),
);

/// Invites a driver (the dashboard's "+ Add Driver").
Future<void> inviteDriver(BuildContext context) => showDialog<void>(
  context: context,
  builder: (_) => const InviteDialog(manager: false),
);

class InviteDialog extends ConsumerStatefulWidget {
  const InviteDialog({required this.manager, super.key});
  final bool manager;

  @override
  ConsumerState<InviteDialog> createState() => _InviteDialogState();
}

class _InviteDialogState extends ConsumerState<InviteDialog> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  String? _nameError;
  String? _phoneError;

  /// Null until the owner changes it: every active vehicle.
  Set<String>? _vehicleIds;
  bool _busy = false;

  Set<String> _chosenVehicles(List<Vehicle> vehicles) =>
      _vehicleIds ??
      {
        for (final v in vehicles)
          if (v.isActive) v.id,
      };

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final l = context.l10n;
    final name = _name.text.trim();
    final phone = normalizeIndianMobile(_phone.text);
    setState(() {
      _nameError = name.isEmpty ? l.required : null;
      _phoneError = phone == null ? l.enterIndianMobile : null;
    });
    if (name.isEmpty || phone == null) return;
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    final ok = await runAction(context, () async {
      final api = ref.read(ownerApiProvider);
      if (widget.manager) {
        await api.inviteManager(name: name, phone: phone);
      } else {
        await api.inviteDriver(
          name: name,
          phone: phone,
          vehicleIds: _chosenVehicles(
            ref.read(fleetVehiclesProvider).value ?? const [],
          ).toList(),
        );
      }
      refreshAfter(ref, {OwnerArea.fleet});
    });
    if (ok) {
      navigator.pop();
    } else if (mounted) {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final vehicles = widget.manager
        ? const <Vehicle>[]
        : ref.watch(fleetVehiclesProvider).value ?? const <Vehicle>[];
    return AlertDialog(
      title: Text(widget.manager ? l.inviteManager : l.inviteDriver),
      scrollable: true,
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.manager ? l.inviteManagerIntro : l.inviteDriverIntro),
            const SizedBox(height: 12),
            TextField(
              key: const Key('invite-name'),
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l.name,
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('invite-phone'),
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l.mobileNumber,
                hintText: '98123 45678',
                errorText: _phoneError,
              ),
            ),
            if (!widget.manager) ...[
              const SizedBox(height: 12),
              LinkSelectField(
                key: const Key('invite-vehicles'),
                label: l.vehiclesOptional,
                helper: l.vehiclesOptionalHint,
                sheetTitle: l.vehicles,
                options: vehicleOptions(l, vehicles),
                value: _chosenVehicles(vehicles),
                emptyText: l.noVehiclesToLink,
                onChanged: (ids) => setState(() => _vehicleIds = ids),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          key: const Key('invite-send'),
          onPressed: _busy ? null : _send,
          child: Text(l.sendInvite),
        ),
      ],
    );
  }
}

/// One driver: name and status, pay (owner only), and their documents.
class DriverScreen extends ConsumerStatefulWidget {
  const DriverScreen({required this.driver, this.initialTab = 0, super.key});
  final Driver driver;

  /// 0 details, 1 documents, 2 schedule.
  final int initialTab;

  @override
  ConsumerState<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends ConsumerState<DriverScreen> {
  late final _name = TextEditingController(text: widget.driver.name);
  late String _status = widget.driver.status;
  late bool _override = widget.driver.payRule != null;
  late PayRule? _rule = widget.driver.payRule;
  String? _problem;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final isOwner = ref.read(isOwnerProvider);
    final rule = _override ? _rule : null;
    if (isOwner && rule != null && !rule.isValid) {
      setState(() => _problem = l.checkPayRule);
      return;
    }
    if (_name.text.trim().isEmpty) {
      setState(() => _problem = l.required);
      return;
    }
    setState(() {
      _problem = null;
      _busy = true;
    });
    final d = widget.driver;
    final navigator = Navigator.of(context);
    if (!await _saveDriver(d)) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    if (!mounted) return;
    final ok = await runAction(context, () async {
      final api = ref.read(ownerApiProvider);
      // Managers can't change pay (403 FORBIDDEN_ROLE), so only owners send it.
      if (isOwner && rule != d.payRule) {
        await api.setDriverPayRule(d.id, rule);
      }
      refreshAfter(ref, {OwnerArea.fleet, OwnerArea.settlements});
    });
    if (ok) {
      navigator.pop();
    } else if (mounted) {
      setState(() => _busy = false);
    }
  }

  /// Saves the name and status. Marking a driver inactive with booked trips
  /// offers to unassign them first; while they're on a trip it's refused.
  Future<bool> _saveDriver(Driver d) async {
    final api = ref.read(ownerApiProvider);
    var unassign = false;
    while (true) {
      try {
        await api.updateDriver(
          d.id,
          name: _name.text.trim(),
          status: _status,
          unassignTrips: unassign,
        );
        if (unassign) refreshAfter(ref, {OwnerArea.trips, OwnerArea.alerts});
        return true;
      } on Object catch (error) {
        if (!mounted) return false;
        final code = error is ApiException ? error.code : null;
        if (code == 'DRIVER_HAS_TRIPS' && !unassign) {
          final details = (error as ApiException).details;
          final trips = details is Map && details['trips'] is List
              ? (details['trips'] as List).whereType<Map<String, dynamic>>()
              : const <Map<String, dynamic>>[];
          if (!await _confirmUnassign(d, trips.toList())) return false;
          unassign = true;
          continue;
        }
        if (code == 'DRIVER_ON_TRIP') {
          await _showOnTrip(d);
          return false;
        }
        return runAction(context, () => Future<void>.error(error));
      }
    }
  }

  Future<bool> _confirmUnassign(
    Driver d,
    List<Map<String, dynamic>> trips,
  ) async {
    final l = context.l10n;
    final fmt = context.fmt;
    String line(Map<String, dynamic> t) {
      final start = DateTime.tryParse('${t['scheduledStartAt']}');
      final to = t['to'];
      final reg = t['registrationNo'];
      return [
        if (start != null) fmt.dayTime(start.toLocal()),
        to is String ? '${t['from']} → $to' : '${t['from']}',
        if (reg is String) formatRegistration(reg),
      ].join(' · ');
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        key: const Key('driver-has-trips-dialog'),
        title: Text(l.driverHasTripsTitle(count: trips.length, name: d.name)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.driverHasTripsBody),
              const SizedBox(height: 12),
              for (final t in trips)
                ListTile(
                  key: ValueKey('driver-has-trip-${t['id']}'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.route, size: 20),
                  title: Text(line(t)),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('driver-has-trips-cancel'),
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l.cancel),
          ),
          FilledButton(
            key: const Key('driver-unassign-and-deactivate'),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l.unassignAndDeactivate),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _showOnTrip(Driver d) {
    final l = context.l10n;
    return showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        key: const Key('driver-on-trip-dialog'),
        title: Text(l.driverOnTripTitle(name: d.name)),
        content: Text(l.driverOnTripBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(),
            child: Text(l.close),
          ),
        ],
      ),
    );
  }

  Future<void> _editVehicles(Driver driver, List<Vehicle> vehicles) async {
    final l = context.l10n;
    final linked = {for (final v in driver.vehicles) v.id};
    final saved = await pickLinks(
      context,
      title: l.editVehicles,
      intro: l.editVehiclesIntro(name: driver.name),
      options: vehicleOptions(l, vehicles, keep: linked),
      // Nothing linked yet: start with every vehicle ticked.
      selected: linked.isEmpty
          ? {
              for (final v in vehicles)
                if (v.isActive) v.id,
            }
          : linked,
      emptyText: l.noVehiclesToLink,
      onSave: (ids) =>
          ref.read(ownerApiProvider).setDriverVehicles(driver.id, ids.toList()),
    );
    if (saved != null) refreshAfter(ref, {OwnerArea.fleet});
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final isOwner = ref.watch(isOwnerProvider);
    final defaultRule = ref.watch(defaultPayRuleProvider).value;
    final d = widget.driver;
    // The list reloads after a change (e.g. its vehicles), so read it from there.
    final current =
        ref
            .watch(driversProvider)
            .value
            ?.where((x) => x.id == d.id)
            .firstOrNull ??
        d;
    final vehicles = ref.watch(fleetVehiclesProvider);
    final query = (vehicleId: null, driverId: d.id, expiringWithinDays: null);
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: Text(d.name),
          bottom: ownerTabBar(context, [
            Tab(key: const Key('driver-tab-details'), text: l.detailsTab),
            Tab(key: const Key('driver-tab-documents'), text: l.documents),
            Tab(key: const Key('driver-tab-schedule'), text: l.schedule),
          ]),
        ),
        body: TabBarView(
          children: [
            ListView(
              padding: const EdgeInsets.all(12),
              children: [
                PageWidth(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SectionCard(
                        child: Column(
                          children: [
                            TextField(
                              controller: _name,
                              decoration: InputDecoration(labelText: l.name),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              key: const Key('driver-status'),
                              isExpanded: true,
                              initialValue: _status,
                              decoration: InputDecoration(labelText: l.status),
                              items: [
                                DropdownMenuItem(
                                  value: 'active',
                                  child: Text(l.active),
                                ),
                                DropdownMenuItem(
                                  value: 'inactive',
                                  child: Text(l.inactiveDriverOption),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => _status = v ?? _status),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                formatPhone(d.phone),
                                style: TextStyle(color: context.tc.muted),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SectionCard(
                        key: const Key('driver-personal'),
                        title: l.personalDetails,
                        actions: [
                          TextButton.icon(
                            key: const Key('driver-edit-details'),
                            onPressed: () => openScreen<bool>(
                              context,
                              DriverProfileFormScreen(
                                driver: current,
                                onSave: (body) async {
                                  await ref
                                      .read(ownerApiProvider)
                                      .updateDriverProfile(d.id, body);
                                  refreshAfter(ref, {OwnerArea.fleet});
                                },
                              ),
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: Text(l.editDetails),
                          ),
                        ],
                        child: DriverPersonalDetails(current),
                      ),
                      SectionCard(
                        key: const Key('driver-pay'),
                        title: l.pay,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!isOwner)
                              Text(
                                l.onlyOwnerPay,
                                key: const Key('only-owner-pay'),
                                style: TextStyle(color: context.tc.muted),
                              ),
                            CheckboxListTile(
                              key: const Key('pay-override'),
                              contentPadding: EdgeInsets.zero,
                              value: _override,
                              title: Text(l.payDifferently),
                              subtitle: defaultRule == null
                                  ? null
                                  : Text(
                                      l.payDefault(
                                        rule: payRuleText(fmt, defaultRule),
                                      ),
                                    ),
                              onChanged: isOwner
                                  ? (v) => setState(() {
                                      _override = v ?? false;
                                      if (_override && _rule == null) {
                                        _rule =
                                            defaultRule ??
                                            PayRule.defaultsFor(
                                              'percent_of_fare',
                                              allowanceToDriver: false,
                                            );
                                      }
                                    })
                                  : null,
                            ),
                            if (_override && _rule != null)
                              PayRuleEditor(
                                value: _rule!,
                                enabled: isOwner,
                                onChanged: (r) => setState(() => _rule = r),
                              ),
                          ],
                        ),
                      ),
                      if (_problem != null)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            _problem!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      FilledButton(
                        key: const Key('driver-save'),
                        onPressed: _busy ? null : _save,
                        child: Text(l.save),
                      ),
                      const SizedBox(height: 12),
                      SectionCard(
                        key: const Key('driver-vehicles'),
                        title: l.vehicles,
                        actions: [
                          TextButton.icon(
                            key: const Key('edit-driver-vehicles'),
                            icon: const Icon(
                              Icons.directions_car_outlined,
                              size: 18,
                            ),
                            label: Text(l.editVehicles),
                            onPressed: vehicles.isLoading
                                ? null
                                : () => _editVehicles(
                                    current,
                                    vehicles.value ?? const [],
                                  ),
                          ),
                        ],
                        child: LinkChips(
                          labels: [
                            for (final v in current.vehicles)
                              formatRegistration(v.registrationNo),
                          ],
                          emptyText: l.noLinkedVehicles,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ListView(
              padding: const EdgeInsets.all(12),
              children: [
                PageWidth(
                  child: SectionCard(
                    title: l.documents,
                    actions: [
                      TextButton.icon(
                        key: const Key('driver-add-document'),
                        icon: const Icon(Icons.add),
                        label: Text(l.addDocument),
                        onPressed: () => openScreen<void>(
                          context,
                          DocumentFormScreen(driverId: d.id),
                        ),
                      ),
                    ],
                    child: DocumentsList(query: query),
                  ),
                ),
              ],
            ),
            TripSchedule(driverId: d.id),
          ],
        ),
      ),
    );
  }
}

/// The fleet's managers, in Settings. Owners invite and remove them; managers
/// see the list read-only.
class ManagersSection extends ConsumerWidget {
  const ManagersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final isOwner = ref.watch(isOwnerProvider);
    final me = ref.watch(authProvider).value?.userId;
    final members = ref.watch(membersProvider);
    return SectionCard(
      key: const Key('managers-section'),
      title: l.managersSection,
      actions: [
        if (isOwner)
          TextButton.icon(
            key: const Key('invite-manager'),
            onPressed: () => _invite(context, ref, manager: true),
            icon: const Icon(Icons.person_add),
            label: Text(l.inviteManager),
          ),
      ],
      child: AsyncView(
        value: members,
        onRetry: () => ref.invalidate(membersProvider),
        builder: (list) {
          final managers = list.where((m) => m.isManager).toList();
          if (managers.isEmpty) return EmptyState(l.noManagersYet);
          return Column(
            children: [
              for (final m in managers)
                ListTile(
                  key: ValueKey('member-${m.id}'),
                  contentPadding: EdgeInsets.zero,
                  leading: InitialsAvatar(
                    m.name ?? formatPhone(m.phone),
                    radius: 16,
                  ),
                  title: Text(m.name ?? formatPhone(m.phone)),
                  subtitle: Text(
                    [
                      formatPhone(m.phone),
                      memberStatusLabel(l, m.status),
                    ].join(' · '),
                  ),
                  trailing: _removeManager(context, ref, m, isOwner, me),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// The owner's "remove manager" button for [m], or null when it doesn't apply.
Widget? _removeManager(
  BuildContext context,
  WidgetRef ref,
  Member m,
  bool isOwner,
  String? me,
) {
  final l = context.l10n;
  if (!isOwner || !m.isManager || m.status == 'suspended' || m.userId == me) {
    return null;
  }
  return IconButton(
    key: ValueKey('remove-manager-${m.id}'),
    tooltip: l.removeManager,
    icon: const Icon(Icons.person_remove),
    onPressed: () async {
      final yes = await confirmAction(
        context,
        title: l.removeManager,
        message: l.removeManagerConfirm(name: m.name ?? formatPhone(m.phone)),
        confirm: l.remove,
      );
      if (!yes || !context.mounted) return;
      await runAction(context, () async {
        await ref.read(ownerApiProvider).removeManager(m.id);
        refreshAfter(ref, {OwnerArea.fleet});
      });
    },
  );
}

/// [DriverScreen] for a driver known only by id (from an alert or a document).
class DriverByIdScreen extends ConsumerWidget {
  const DriverByIdScreen({
    required this.driverId,
    this.initialTab = 0,
    super.key,
  });
  final String driverId;

  /// See [DriverScreen.initialTab].
  final int initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drivers = ref.watch(driversProvider);
    final driver = drivers.value?.where((d) => d.id == driverId).firstOrNull;
    if (driver != null) {
      return DriverScreen(driver: driver, initialTab: initialTab);
    }
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.drivers)),
      body: RefreshPage(
        onRefresh: () => ref.refresh(driversProvider.future),
        children: [
          AsyncView(
            value: drivers,
            onRetry: () => ref.invalidate(driversProvider),
            builder: (_) => EmptyState(context.l10n.noItems),
          ),
        ],
      ),
    );
  }
}

/// Opens the vehicle or driver a document belongs to, where its documents live.
void openDocumentOwner(
  BuildContext context, {
  String? vehicleId,
  String? driverId,
}) {
  if (vehicleId != null) {
    openScreen<void>(context, VehicleDetailScreen(vehicleId: vehicleId));
  } else if (driverId != null) {
    // Straight to their Documents tab.
    openScreen<void>(
      context,
      DriverByIdScreen(driverId: driverId, initialTab: 1),
    );
  }
}
