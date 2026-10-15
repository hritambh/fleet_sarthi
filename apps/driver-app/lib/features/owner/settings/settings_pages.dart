import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/theme.dart';
import '../../../core/api/models.dart';
import '../../../core/api/owner_models.dart';
import '../../common/format.dart';
import '../owner_providers.dart';
import '../owner_widgets.dart';
import '../pay_rule_editor.dart';
import '../people_screens.dart';
import '../settings_screen.dart' show parseDayList;
import 'settings_widgets.dart';

/// A settings page until its data arrives: the title with a spinner, or the
/// error and Retry.
Widget _loading<T>(
  String title,
  IconData icon,
  AsyncValue<T> value,
  VoidCallback onRetry,
  Widget Function(T data) builder,
) => switch (value) {
  AsyncData(:final value) => builder(value),
  _ => SettingsScaffold(
    title: title,
    icon: icon,
    savable: false,
    children: [
      AsyncView(
        value: value,
        onRetry: onRetry,
        builder: (_) => const SizedBox(),
      ),
    ],
  ),
};

/// Whether every value in [values] loaded; the first error or loading state otherwise.
AsyncValue<List<Object>> _all(List<AsyncValue<Object>> values) {
  for (final v in values) {
    if (v is AsyncError<Object>) return AsyncError(v.error, v.stackTrace);
  }
  if (values.any((v) => !v.hasValue)) return const AsyncLoading();
  return AsyncData([for (final v in values) v.requireValue]);
}

// ───────── General ─────────

class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _loading(
    context.l10n.settingsGeneral,
    Icons.tune,
    ref.watch(orgProfileProvider),
    () => ref.invalidate(orgProfileProvider),
    (profile) => _GeneralForm(profile, editable: ref.watch(isOwnerProvider)),
  );
}

class _GeneralForm extends ConsumerStatefulWidget {
  const _GeneralForm(this.profile, {required this.editable});
  final OrgProfile profile;
  final bool editable;

  @override
  ConsumerState<_GeneralForm> createState() => _GeneralFormState();
}

class _GeneralFormState extends ConsumerState<_GeneralForm> {
  late String _saved = widget.profile.name;
  late final _name = TextEditingController(text: _saved);
  var _saving = false;

  bool get _dirty => _name.text.trim() != _saved;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!OrgProfile.isValidName(_name.text)) return;
    setState(() => _saving = true);
    final ok = await runAction(context, () async {
      final profile = await ref.read(ownerApiProvider).renameOrg(_name.text);
      _saved = profile.name;
      _name.text = profile.name;
      // The fleet's name comes with each membership: reload them.
      await ref.read(authProvider.notifier).refreshFleets();
      refreshAfter(ref, {OwnerArea.settings});
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) showSaved(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final invalid = _dirty && !OrgProfile.isValidName(_name.text);
    return SettingsScaffold(
      title: l.settingsGeneral,
      icon: Icons.tune,
      editable: widget.editable,
      dirty: _dirty,
      saving: _saving,
      onSave: invalid ? null : _save,
      onCancel: () => setState(() => _name.text = _saved),
      children: [
        SettingsSection(
          children: [
            SettingTile(
              title: l.fleetNameLabel,
              help: l.fleetNameHelp,
              affects: l.fleetNameAffects,
              when: l.fleetNameWhen,
              control: TextField(
                key: const Key('settings-fleet-name'),
                controller: _name,
                enabled: widget.editable,
                maxLength: 100,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: l.fleetNameLabel,
                  errorText: invalid ? l.fleetNameInvalid : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ───────── Trips & drivers ─────────

class TripRulesScreen extends ConsumerWidget {
  const TripRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _loading(
    context.l10n.settingsTrips,
    Icons.route_outlined,
    _all([ref.watch(ownerWorkflowProvider), ref.watch(auditSettingsProvider)]),
    () => refreshAfter(ref, {OwnerArea.settings}),
    (data) => _TripRulesForm(
      data[0] as WorkflowSettings,
      data[1] as AuditSettings,
      editable: ref.watch(isOwnerProvider),
    ),
  );
}

class _TripRulesForm extends ConsumerStatefulWidget {
  const _TripRulesForm(this.workflow, this.audit, {required this.editable});
  final WorkflowSettings workflow;
  final AuditSettings audit;
  final bool editable;

  @override
  ConsumerState<_TripRulesForm> createState() => _TripRulesFormState();
}

class _TripRulesFormState extends ConsumerState<_TripRulesForm> {
  late WorkflowSettings _savedRules = widget.workflow;
  late AuditSettings _savedAudit = widget.audit;
  late WorkflowSettings _rules = _savedRules;
  late final _odo = TextEditingController(
    text: _num(_savedAudit.odoGpsTolerancePct),
  );
  var _saving = false;

  static String _num(num v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';

  double? get _odoValue =>
      NumberSetting.parse(_odo.text, min: 1, max: 50)?.toDouble();

  bool get _dirty =>
      _rules != _savedRules ||
      _odo.text.trim() != _num(_savedAudit.odoGpsTolerancePct);

  @override
  void dispose() {
    _odo.dispose();
    super.dispose();
  }

  void _cancel() => setState(() {
    _rules = _savedRules;
    _odo.text = _num(_savedAudit.odoGpsTolerancePct);
  });

  void _reset() {
    setState(() {
      _rules = _rules.copyWith(
        driversCanCreateTrips: WorkflowSettings.defaults.driversCanCreateTrips,
        driversCanAddCharges: WorkflowSettings.defaults.driversCanAddCharges,
      );
      _odo.text = _num(AuditSettings.defaults.odoGpsTolerancePct);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.settingsResetDone)));
  }

  Future<void> _save() async {
    final odo = _odoValue;
    if (odo == null) return;
    setState(() => _saving = true);
    final api = ref.read(ownerApiProvider);
    final ok = await runAction(context, () async {
      if (_rules != _savedRules) {
        _savedRules = await api.updateWorkflowSettings(_rules);
      }
      if (odo != _savedAudit.odoGpsTolerancePct) {
        _savedAudit = await api.updateAuditSettings(
          _savedAudit.copyWith(odoGpsTolerancePct: odo),
        );
      }
      refreshAfter(ref, {OwnerArea.settings});
    });
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (ok) {
        _rules = _savedRules;
        _odo.text = _num(_savedAudit.odoGpsTolerancePct);
      }
    });
    if (ok) showSaved(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final edit = widget.editable;
    return SettingsScaffold(
      title: l.settingsTrips,
      icon: Icons.route_outlined,
      editable: edit,
      dirty: _dirty,
      saving: _saving,
      onSave: _odoValue == null ? null : _save,
      onCancel: _cancel,
      onReset: _reset,
      children: [
        SettingsSection(
          children: [
            Column(
              children: [
                SettingSwitch(
                  switchKey: const Key('rule-driver-trips'),
                  title: l.ruleDriverTrips,
                  help: l.ruleDriverTripsHelp,
                  affects: l.ruleDriverTripsAffects,
                  when: l.ruleNewTripsOnly,
                  value: _rules.driversCanCreateTrips,
                  onChanged: edit
                      ? (v) => setState(
                          () => _rules = _rules.copyWith(
                            driversCanCreateTrips: v,
                          ),
                        )
                      : null,
                ),
                const Divider(),
                SettingSwitch(
                  switchKey: const Key('rule-driver-charges'),
                  title: l.ruleDriverCharges,
                  help: l.ruleDriverChargesHelp,
                  affects: l.ruleDriverChargesAffects,
                  when: l.ruleNewChargesOnly,
                  value: _rules.driversCanAddCharges,
                  onChanged: edit
                      ? (v) => setState(
                          () =>
                              _rules = _rules.copyWith(driversCanAddCharges: v),
                        )
                      : null,
                ),
                const Divider(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: TaxcyColors.muted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.ruleOfflineNote,
                        style: const TextStyle(
                          color: TaxcyColors.muted,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        SettingsSection(
          children: [
            SettingTile(
              title: l.odoTolerance,
              help: l.odoToleranceHint,
              affects: l.odoToleranceAffects,
              when: l.odoToleranceWhen,
              control: NumberSetting(
                fieldKey: const Key('audit-odo'),
                label: l.odoTolerance,
                controller: _odo,
                min: 1,
                max: 50,
                defaultValue: AuditSettings.defaults.odoGpsTolerancePct,
                enabled: edit,
                onChanged: () => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ───────── Fuel audit ─────────

class FuelRulesScreen extends ConsumerWidget {
  const FuelRulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _loading(
    context.l10n.settingsFuel,
    Icons.local_gas_station_outlined,
    _all([ref.watch(ownerWorkflowProvider), ref.watch(auditSettingsProvider)]),
    () => refreshAfter(ref, {OwnerArea.settings}),
    (data) => _FuelRulesForm(
      data[0] as WorkflowSettings,
      data[1] as AuditSettings,
      editable: ref.watch(isOwnerProvider),
    ),
  );
}

/// One audit threshold: its key, range and whether it's a whole number.
typedef _Threshold = ({String key, num min, num max, bool whole});

const _thresholds = <_Threshold>[
  (key: 'k', min: 0.5, max: 5, whole: false),
  (key: 'min', min: 1, max: 20, whole: true),
  (key: 'pct', min: 1, max: 80, whole: false),
  (key: 'alpha', min: 0.05, max: 0.9, whole: false),
];

num _thresholdOf(AuditSettings a, String key) => switch (key) {
  'k' => a.fuelKSigma,
  'min' => a.fuelMinCycles,
  'pct' => a.fuelPctThreshold,
  _ => a.fuelEwmaAlpha,
};

class _FuelRulesForm extends ConsumerStatefulWidget {
  const _FuelRulesForm(this.workflow, this.audit, {required this.editable});
  final WorkflowSettings workflow;
  final AuditSettings audit;
  final bool editable;

  @override
  ConsumerState<_FuelRulesForm> createState() => _FuelRulesFormState();
}

class _FuelRulesFormState extends ConsumerState<_FuelRulesForm> {
  late WorkflowSettings _savedRules = widget.workflow;
  late AuditSettings _savedAudit = widget.audit;
  late bool _receipt = _savedRules.fuelReceiptRequired;
  late final _fields = {
    for (final t in _thresholds)
      t.key: TextEditingController(
        text: _num(_thresholdOf(_savedAudit, t.key)),
      ),
  };
  var _saving = false;

  static String _num(num v) => v == v.roundToDouble() ? '${v.toInt()}' : '$v';

  num? _value(_Threshold t) => NumberSetting.parse(
    _fields[t.key]!.text,
    min: t.min,
    max: t.max,
    whole: t.whole,
  );

  bool get _valid => _thresholds.every((t) => _value(t) != null);

  bool get _dirty =>
      _receipt != _savedRules.fuelReceiptRequired ||
      _thresholds.any(
        (t) =>
            _fields[t.key]!.text.trim() !=
            _num(_thresholdOf(_savedAudit, t.key)),
      );

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _fill(AuditSettings a, bool receipt) => setState(() {
    _receipt = receipt;
    for (final t in _thresholds) {
      _fields[t.key]!.text = _num(_thresholdOf(a, t.key));
    }
  });

  void _reset() {
    _fill(
      AuditSettings.defaults,
      WorkflowSettings.defaults.fuelReceiptRequired,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.settingsResetDone)));
  }

  Future<void> _save() async {
    if (!_valid) return;
    final values = {for (final t in _thresholds) t.key: _value(t)!};
    final audit = _savedAudit.copyWith(
      fuelKSigma: values['k']!.toDouble(),
      fuelMinCycles: values['min']!.toInt(),
      fuelPctThreshold: values['pct']!.toDouble(),
      fuelEwmaAlpha: values['alpha']!.toDouble(),
    );
    setState(() => _saving = true);
    final api = ref.read(ownerApiProvider);
    final ok = await runAction(context, () async {
      if (_receipt != _savedRules.fuelReceiptRequired) {
        _savedRules = await api.updateWorkflowSettings(
          _savedRules.copyWith(fuelReceiptRequired: _receipt),
        );
      }
      if (_thresholds.any(
        (t) => values[t.key] != _thresholdOf(_savedAudit, t.key),
      )) {
        _savedAudit = await api.updateAuditSettings(audit);
      }
      refreshAfter(ref, {OwnerArea.settings, OwnerArea.fuel});
    });
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      _fill(_savedAudit, _savedRules.fuelReceiptRequired);
      showSaved(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final edit = widget.editable;
    final labels = {
      'k': (l.fuelKSigma, l.fuelKSigmaHint),
      'min': (l.fuelMinCycles, l.fuelMinCyclesHint),
      'pct': (l.fuelPct, l.fuelPctHint),
      'alpha': (l.fuelAlpha, l.fuelAlphaHint),
    };
    return SettingsScaffold(
      title: l.settingsFuel,
      icon: Icons.local_gas_station_outlined,
      editable: edit,
      dirty: _dirty,
      saving: _saving,
      onSave: _valid ? _save : null,
      onCancel: () => _fill(_savedAudit, _savedRules.fuelReceiptRequired),
      onReset: _reset,
      children: [
        SettingsSection(
          children: [
            SettingSwitch(
              switchKey: const Key('rule-fuel-receipt'),
              title: l.ruleReceipt,
              help: l.ruleReceiptHelp,
              affects: l.ruleReceiptAffects,
              when: l.ruleNewFillsOnly,
              value: _receipt,
              onChanged: edit ? (v) => setState(() => _receipt = v) : null,
            ),
          ],
        ),
        SettingsSection(
          children: [
            SettingTile(
              title: l.fuelThresholdsTitle,
              help: l.fuelIntro,
              affects: l.fuelThresholdsAffects,
              when: l.fuelThresholdsWhen,
              control: Column(
                children: [
                  for (final t in _thresholds)
                    NumberSetting(
                      fieldKey: Key('audit-${t.key}'),
                      label: labels[t.key]!.$1,
                      hint: labels[t.key]!.$2,
                      controller: _fields[t.key]!,
                      min: t.min,
                      max: t.max,
                      whole: t.whole,
                      defaultValue: _thresholdOf(AuditSettings.defaults, t.key),
                      enabled: edit,
                      onChanged: () => setState(() {}),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ───────── Documents & reminders ─────────

/// Reminder days typed as "30, 7, 1": 1–5 whole numbers, each 0–365; null otherwise.
List<int>? parseReminderDays(String text) {
  final days = parseDayList(text);
  if (days == null || days.isEmpty || days.length > 5) return null;
  return days.every((d) => d >= 0 && d <= 365) ? days : null;
}

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _loading(
    context.l10n.settingsReminders,
    Icons.notifications_active_outlined,
    ref.watch(auditSettingsProvider),
    () => ref.invalidate(auditSettingsProvider),
    (audit) => _RemindersForm(audit, editable: ref.watch(isOwnerProvider)),
  );
}

class _RemindersForm extends ConsumerStatefulWidget {
  const _RemindersForm(this.audit, {required this.editable});
  final AuditSettings audit;
  final bool editable;

  @override
  ConsumerState<_RemindersForm> createState() => _RemindersFormState();
}

class _RemindersFormState extends ConsumerState<_RemindersForm> {
  late AuditSettings _saved = widget.audit;
  late final _days = TextEditingController(
    text: _saved.docAlertDays.join(', '),
  );
  var _saving = false;

  List<int>? get _value => parseReminderDays(_days.text);

  bool get _dirty {
    final v = _value;
    return v == null || v.join(',') != _saved.docAlertDays.join(',');
  }

  @override
  void dispose() {
    _days.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final days = _value;
    if (days == null) return;
    setState(() => _saving = true);
    final ok = await runAction(context, () async {
      _saved = await ref
          .read(ownerApiProvider)
          .updateAuditSettings(_saved.copyWith(docAlertDays: days));
      refreshAfter(ref, {OwnerArea.settings, OwnerArea.documents});
    });
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (ok) _days.text = _saved.docAlertDays.join(', ');
    });
    if (ok) showSaved(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final invalid = _value == null;
    return SettingsScaffold(
      title: l.settingsReminders,
      icon: Icons.notifications_active_outlined,
      editable: widget.editable,
      dirty: _dirty,
      saving: _saving,
      onSave: invalid ? null : _save,
      onCancel: () =>
          setState(() => _days.text = _saved.docAlertDays.join(', ')),
      onReset: () {
        setState(
          () => _days.text = AuditSettings.defaults.docAlertDays.join(', '),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l.settingsResetDone)));
      },
      children: [
        SettingsSection(
          children: [
            SettingTile(
              title: l.docAlertDays,
              help: l.docAlertDaysHint,
              affects: l.remindersAffects,
              when: l.remindersWhen,
              control: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    key: const Key('audit-days'),
                    controller: _days,
                    enabled: widget.editable,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: l.docAlertDays,
                      helperText: l.settingsDefaultIs(
                        value: AuditSettings.defaults.docAlertDays.join(', '),
                      ),
                      errorText: invalid ? l.settingsDaysInvalid : null,
                      errorMaxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l.remindersSeverity,
                    style: const TextStyle(
                      color: TaxcyColors.muted,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ───────── Driver pay ─────────

class PaySettingsScreen extends ConsumerWidget {
  const PaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => _loading(
    context.l10n.defaultDriverPay,
    Icons.payments_outlined,
    ref.watch(defaultPayRuleProvider),
    () => ref.invalidate(defaultPayRuleProvider),
    (rule) => _PayForm(rule, editable: ref.watch(isOwnerProvider)),
  );
}

class _PayForm extends ConsumerStatefulWidget {
  const _PayForm(this.rule, {required this.editable});
  final PayRule rule;
  final bool editable;

  @override
  ConsumerState<_PayForm> createState() => _PayFormState();
}

class _PayFormState extends ConsumerState<_PayForm> {
  late PayRule _saved = widget.rule;
  late PayRule _rule = _saved;
  var _saving = false;

  Future<void> _save() async {
    if (!_rule.isValid) return;
    setState(() => _saving = true);
    final ok = await runAction(context, () async {
      _saved = await ref.read(ownerApiProvider).updateDefaultPayRule(_rule);
      refreshAfter(ref, {OwnerArea.settings, OwnerArea.settlements});
    });
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (ok) _rule = _saved;
    });
    if (ok) showSaved(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SettingsScaffold(
      title: l.defaultDriverPay,
      icon: Icons.payments_outlined,
      editable: widget.editable,
      dirty: _rule != _saved,
      saving: _saving,
      onSave: _rule.isValid ? _save : null,
      onCancel: () => setState(() => _rule = _saved),
      children: [
        SettingsSection(
          children: [
            SettingTile(
              title: l.defaultDriverPay,
              help: l.defaultPayIntro,
              affects: l.payAffects,
              when: l.payWhen,
              control: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PayRuleEditor(
                    value: _rule,
                    enabled: widget.editable,
                    onChanged: (r) => setState(() => _rule = r),
                  ),
                  if (!_rule.isValid)
                    Text(
                      l.checkPayRule,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ───────── Team & roles ─────────

class TeamSettingsScreen extends ConsumerWidget {
  const TeamSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final roles = [
      (Icons.verified_user_outlined, l.roleOwner, l.roleOwnerCan),
      (Icons.manage_accounts_outlined, l.roleManager, l.roleManagerCan),
      (Icons.badge_outlined, l.roleDriver, l.roleDriverCan),
    ];
    return SettingsScaffold(
      title: l.settingsTeam,
      icon: Icons.group_outlined,
      savable: false,
      onRefresh: () async {
        ref.invalidate(membersProvider);
        await ref.read(membersProvider.future);
      },
      children: [
        const SizedBox(height: 12),
        const ManagersSection(),
        SettingsSection(
          key: const Key('settings-roles'),
          title: l.rolesTitle,
          last: true,
          children: [
            for (final (icon, name, can) in roles)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(icon),
                title: Text(name),
                subtitle: Text(can),
              ),
          ],
        ),
      ],
    );
  }
}
