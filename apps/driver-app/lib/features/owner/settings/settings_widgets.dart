import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../common/format.dart';
import '../alerts_inbox.dart';
import '../owner_widgets.dart';

/// One settings page: a title, a read-only banner for managers, the page's
/// settings, and (when editable) Save / Cancel / Reset to defaults. Leaving
/// with unsaved changes asks first.
class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({
    required this.title,
    required this.children,
    this.editable = true,
    this.dirty = false,
    this.saving = false,
    this.onSave,
    this.onCancel,
    this.onReset,
    this.onRefresh,
    this.savable = true,
    super.key,
  });

  final String title;
  final List<Widget> children;

  /// False for managers: controls are shown disabled, with a banner.
  final bool editable;

  /// There are edits not yet saved.
  final bool dirty;
  final bool saving;

  /// Saves the edits; null while they aren't valid (Save shows disabled).
  final VoidCallback? onSave;

  /// The page has settings to save (Team & roles saves as it goes: no bar).
  final bool savable;

  /// Puts the form back to what's saved.
  final VoidCallback? onCancel;

  /// Fills in a new fleet's values (Save still applies them); null when the
  /// page has no defaults.
  final VoidCallback? onReset;
  final Future<void> Function()? onRefresh;

  Future<void> _confirmLeave(BuildContext context) async {
    final l = context.l10n;
    final navigator = Navigator.of(context);
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        key: const Key('settings-discard-dialog'),
        title: Text(l.settingsDiscardTitle),
        content: Text(l.settingsDiscardBody),
        actions: [
          TextButton(
            key: const Key('settings-keep-editing'),
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l.keepEditing),
          ),
          TextButton(
            key: const Key('settings-discard'),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l.discard),
          ),
        ],
      ),
    );
    if (discard ?? false) {
      onCancel?.call();
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final list = ListView(
      padding: isDesktop(context)
          ? const EdgeInsets.fromLTRB(28, 24, 28, 24)
          : const EdgeInsets.fromLTRB(12, 8, 12, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        for (final child in [
          if (!editable)
            Card(
              key: const Key('settings-owner-only'),
              color: TaxcyColors.blue50,
              child: ListTile(
                leading: const Icon(Icons.lock_outline),
                title: Text(l.settingsOwnerOnly),
              ),
            ),
          ...children,
        ])
          PageWidth(child: child),
      ],
    );
    return PopScope(
      canPop: !dirty || saving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave(context);
      },
      child: Scaffold(
        appBar: AppBar(title: Text(title), actions: const [AlertsBell()]),
        body: onRefresh == null
            ? list
            : RefreshIndicator(onRefresh: onRefresh!, child: list),
        bottomNavigationBar: !editable || !savable
            ? null
            : SafeArea(
                child: Material(
                  elevation: 6,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (dirty)
                          Text(
                            l.settingsUnsaved,
                            key: const Key('settings-unsaved'),
                            style: const TextStyle(color: TaxcyColors.muted),
                          ),
                        if (onReset != null)
                          TextButton(
                            key: const Key('settings-reset'),
                            onPressed: saving ? null : onReset,
                            child: Text(l.settingsResetDefaults),
                          ),
                        if (dirty)
                          OutlinedButton(
                            key: const Key('settings-cancel'),
                            onPressed: saving ? null : onCancel,
                            child: Text(l.cancel),
                          ),
                        FilledButton(
                          key: const Key('settings-save'),
                          onPressed: dirty && !saving ? onSave : null,
                          child: Text(l.settingsSaveChanges),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// One setting, explained: its name, what it does in plain words, what part
/// of the app it affects and when a change takes effect, then its control.
class SettingTile extends StatelessWidget {
  const SettingTile({
    required this.title,
    required this.help,
    required this.affects,
    required this.when,
    required this.control,
    this.controlBeside = false,
    super.key,
  });

  final String title;
  final String help;
  final String affects;
  final String when;
  final Widget control;

  /// The control sits at the right of the title (a switch) rather than below.
  final bool controlBeside;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    const small = TextStyle(color: TaxcyColors.muted, fontSize: 12.5);
    final heading = Text(title, style: theme.textTheme.titleMedium);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (controlBeside)
            Row(
              children: [
                Expanded(child: heading),
                const SizedBox(width: 8),
                control,
              ],
            )
          else
            heading,
          const SizedBox(height: 4),
          Text(help, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          _Note(Icons.ads_click, l.settingsAffects(area: affects), small),
          _Note(Icons.schedule, l.settingsApplies(when: when), small),
          if (!controlBeside) ...[const SizedBox(height: 10), control],
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.icon, this.text, this.style);

  final IconData icon;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 14, color: TaxcyColors.muted),
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: style)),
      ],
    ),
  );
}

/// An on/off setting: [SettingTile] with a switch beside its name.
class SettingSwitch extends StatelessWidget {
  const SettingSwitch({
    required this.switchKey,
    required this.title,
    required this.help,
    required this.affects,
    required this.when,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final Key switchKey;
  final String title;
  final String help;
  final String affects;
  final String when;
  final bool value;

  /// Null shows the switch disabled (managers).
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SettingTile(
    title: title,
    help: help,
    affects: affects,
    when: when,
    controlBeside: true,
    control: Semantics(
      label: title,
      child: Switch(key: switchKey, value: value, onChanged: onChanged),
    ),
  );
}

/// A number field with its range check: [error] under it while the text
/// isn't a number in [min]–[max].
class NumberSetting extends StatelessWidget {
  const NumberSetting({
    required this.fieldKey,
    required this.label,
    required this.controller,
    required this.min,
    required this.max,
    required this.defaultValue,
    required this.enabled,
    required this.onChanged,
    this.hint,
    this.whole = false,
    super.key,
  });

  final Key fieldKey;
  final String label;
  final TextEditingController controller;
  final num min;
  final num max;
  final num defaultValue;
  final bool enabled;
  final VoidCallback onChanged;
  final String? hint;

  /// Whole numbers only.
  final bool whole;

  /// The value if it's valid, else null.
  static num? parse(
    String text, {
    required num min,
    required num max,
    bool whole = false,
  }) {
    final value = whole
        ? int.tryParse(text.trim())
        : double.tryParse(text.trim());
    if (value == null || value < min || value > max) return null;
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    // 2, 0.3 and 0.05, not 2.00 and 0.30.
    String show(num v) => fmt.number(
      v,
      decimals: v == v.roundToDouble()
          ? 0
          : (v * 10 == (v * 10).roundToDouble() ? 1 : 2),
    );
    final valid =
        parse(controller.text, min: min, max: max, whole: whole) != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        key: fieldKey,
        controller: controller,
        enabled: enabled,
        onChanged: (_) => onChanged(),
        keyboardType: TextInputType.numberWithOptions(decimal: !whole),
        decoration: InputDecoration(
          labelText: label,
          helperText: [
            ?hint,
            l.settingsDefaultIs(value: show(defaultValue)),
          ].join('\n'),
          helperMaxLines: 4,
          errorText: valid
              ? null
              : l.settingsRange(min: show(min), max: show(max)),
          errorMaxLines: 2,
        ),
      ),
    );
  }
}

/// Shows a "Saved." snackbar.
void showSaved(BuildContext context) => ScaffoldMessenger.of(
  context,
).showSnackBar(SnackBar(content: Text(context.l10n.settingsSaved)));
