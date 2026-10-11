import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/api/models.dart';
import '../../core/api/owner_models.dart';
import '../common/format.dart';
import 'documents_screen.dart';
import 'links.dart';
import 'owner_providers.dart';
import 'owner_text.dart';
import 'owner_widgets.dart';
import 'pay_rule_editor.dart';

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
        actions: action.headerActions(context),
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
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            key: ValueKey('driver-${d.id}'),
                            leading: const Icon(Icons.person),
                            title: Text(d.name),
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
                                  tone: d.isActive
                                      ? Tone.success
                                      : Tone.neutral,
                                ),
                                if (d.membershipStatus == 'invited')
                                  ToneChip(l.notSignedInYet, tone: Tone.brand),
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
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
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
                  InitialsAvatar(d.name, radius: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          formatPhone(d.phone),
                          style: const TextStyle(color: TaxcyColors.muted),
                        ),
                      ],
                    ),
                  ),
                  ToneChip(
                    d.isActive ? l.active : l.inactive,
                    tone: d.isActive ? Tone.success : Tone.neutral,
                  ),
                ],
              ),
              if (d.membershipStatus == 'invited') ...[
                const SizedBox(height: 8),
                ToneChip(l.notSignedInYet, tone: Tone.brand),
              ],
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              if (pay != null)
                Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 18,
                      color: TaxcyColors.muted,
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
  Set<String> _vehicleIds = {};
  bool _busy = false;

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
          vehicleIds: _vehicleIds.toList(),
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
                value: _vehicleIds,
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
  const DriverScreen({required this.driver, super.key});
  final Driver driver;

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
    final ok = await runAction(context, () async {
      final api = ref.read(ownerApiProvider);
      await api.updateDriver(d.id, name: _name.text.trim(), status: _status);
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

  Future<void> _editVehicles(Driver driver, List<Vehicle> vehicles) async {
    final l = context.l10n;
    final linked = {for (final v in driver.vehicles) v.id};
    final saved = await pickLinks(
      context,
      title: l.editVehicles,
      intro: l.editVehiclesIntro(name: driver.name),
      options: vehicleOptions(l, vehicles, keep: linked),
      selected: linked,
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
    return Scaffold(
      appBar: AppBar(title: Text(d.name)),
      body: ListView(
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
                          style: const TextStyle(color: TaxcyColors.muted),
                        ),
                      ),
                    ],
                  ),
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
                          style: const TextStyle(color: TaxcyColors.muted),
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
                      icon: const Icon(Icons.directions_car_outlined, size: 18),
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
                SectionCard(
                  title: l.documents,
                  actions: [
                    TextButton.icon(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Everyone with access to the org. Owners invite and remove managers.
class MembersScreen extends ConsumerWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final isOwner = ref.watch(isOwnerProvider);
    final me = ref.watch(authProvider).value?.userId;
    final members = ref.watch(membersProvider);
    final action = PageAction(
      key: const Key('invite-manager'),
      icon: Icons.person_add,
      label: l.inviteManager,
      onPressed: () => _invite(context, ref, manager: true),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(l.members),
        actions: isOwner ? action.headerActions(context) : const [],
      ),
      floatingActionButton: isOwner ? action.fab(context) : null,
      body: RefreshPage(
        onRefresh: () => ref.refresh(membersProvider.future),
        children: [
          Text(l.membersIntro, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          AsyncView(
            value: members,
            onRetry: () => ref.invalidate(membersProvider),
            builder: (list) => isDesktop(context)
                ? DesktopTable(
                    key: const Key('member-table'),
                    columns: [
                      TableColumn(l.name, flex: 4),
                      TableColumn(l.mobileNumber, flex: 3),
                      TableColumn(l.colRole, flex: 3),
                      TableColumn(l.status),
                      const TableColumn('', flex: 1, end: true),
                    ],
                    rows: [
                      for (final m in list)
                        TableRowData(
                          key: ValueKey('member-${m.id}'),
                          cells: [
                            Row(
                              children: [
                                InitialsAvatar(
                                  m.name ?? formatPhone(m.phone),
                                  radius: 16,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    m.name ?? formatPhone(m.phone),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              formatPhone(m.phone),
                              style: const TextStyle(color: TaxcyColors.muted),
                            ),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                for (final r in m.roles)
                                  ToneChip(
                                    roleLabel(l, r),
                                    tone: r == 'owner'
                                        ? Tone.brand
                                        : Tone.neutral,
                                  ),
                              ],
                            ),
                            ToneChip(
                              memberStatusLabel(l, m.status),
                              tone: m.status == 'active'
                                  ? Tone.success
                                  : m.status == 'suspended'
                                  ? Tone.danger
                                  : Tone.warning,
                            ),
                            _removeManager(context, ref, m, isOwner, me) ??
                                const SizedBox.shrink(),
                          ],
                        ),
                    ],
                  )
                : Column(
                    children: [
                      for (final m in list)
                        Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            key: ValueKey('member-${m.id}'),
                            title: Text(m.name ?? formatPhone(m.phone)),
                            subtitle: Text(
                              [
                                formatPhone(m.phone),
                                m.roles.map((r) => roleLabel(l, r)).join(', '),
                                memberStatusLabel(l, m.status),
                              ].join(' · '),
                            ),
                            trailing: _removeManager(
                              context,
                              ref,
                              m,
                              isOwner,
                              me,
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
