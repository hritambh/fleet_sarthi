import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../common/format.dart';
import '../alerts_inbox.dart';

/// Present above a settings page shown inside the desktop settings layout
/// (nav column + page) rather than pushed on its own. The page then draws its
/// own header instead of an app bar, and reports unsaved edits through
/// [dirty] so the nav can ask before switching pages.
class SettingsHost extends InheritedWidget {
  const SettingsHost({required this.dirty, required super.child, super.key});

  final ValueNotifier<bool> dirty;

  static SettingsHost? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsHost>();

  @override
  bool updateShouldNotify(SettingsHost oldWidget) => dirty != oldWidget.dirty;
}

/// Asks before throwing away unsaved settings; true to discard.
Future<bool> confirmDiscardSettings(BuildContext context) async {
  final l = context.l10n;
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
  return discard ?? false;
}

/// One settings page: a header (an app bar on its own, an icon and title
/// inside the desktop layout), a read-only note for managers, the page's
/// sections on white, and (when editable) Save / Cancel / Reset to defaults.
/// Leaving with unsaved changes asks first.
class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({
    required this.title,
    required this.icon,
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
  final IconData icon;
  final List<Widget> children;

  /// False for managers: controls are shown disabled, with a note.
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

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final host = SettingsHost.maybeOf(context);
    if (host != null) {
      final unsaved = dirty && editable && !saving;
      if (host.dirty.value != unsaved) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => host.dirty.value = unsaved,
        );
      }
    }
    final wide = MediaQuery.sizeOf(context).width >= 700;
    final list = ListView(
      padding: EdgeInsets.fromLTRB(wide ? 40 : 16, 8, wide ? 40 : 16, 32),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Align(
          alignment: AlignmentDirectional.topStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!editable)
                  Container(
                    key: const Key('settings-owner-only'),
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.tc.blue50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: context.tc.blue800,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text(l.settingsOwnerOnly)),
                      ],
                    ),
                  ),
                ...children,
              ],
            ),
          ),
        ),
      ],
    );
    final body = ColoredBox(
      color: context.tc.surface,
      child: onRefresh == null
          ? list
          : RefreshIndicator(onRefresh: onRefresh!, child: list),
    );
    final bar = !editable || !savable
        ? null
        : _SaveBar(
            dirty: dirty,
            saving: saving,
            onSave: onSave,
            onCancel: onCancel,
            onReset: onReset,
          );

    if (host != null) {
      // Inside the desktop layout: a header like "⚙ General settings".
      return Material(
        color: context.tc.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 20, 40, 16),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: context.tc.ink),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    key: const Key('settings-page-title'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(child: body),
            ?bar,
          ],
        ),
      );
    }
    return PopScope(
      canPop: !dirty || saving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (await confirmDiscardSettings(context)) {
          onCancel?.call();
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: context.tc.surface,
        appBar: AppBar(title: Text(title), actions: const [AlertsBell()]),
        body: body,
        bottomNavigationBar: bar == null ? null : SafeArea(child: bar),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.dirty,
    required this.saving,
    required this.onSave,
    required this.onCancel,
    required this.onReset,
  });

  final bool dirty;
  final bool saving;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.tc.surface,
        border: Border(top: BorderSide(color: context.tc.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
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
                style: TextStyle(color: context.tc.muted),
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
    );
  }
}

/// A group of settings on a page: an optional heading and description, its
/// settings, and a thin rule below, like the sections of a form.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.children,
    this.title,
    this.description,
    this.last = false,
    super.key,
  });

  final String? title;
  final String? description;
  final List<Widget> children;

  /// No rule below the last section.
  final bool last;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 20),
      if (title case final title?)
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      if (description case final description?)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            description,
            style: TextStyle(color: context.tc.muted, fontSize: 13),
          ),
        ),
      ...children,
      const SizedBox(height: 12),
      if (!last) const Divider(height: 1),
    ],
  );
}

/// One setting, explained: its name, what it does in plain words, what part
/// of the app it affects and when a change takes effect, then its control.
/// On a wide page the explanation sits on the left and the control on the
/// right; on a phone the control goes below (a switch stays beside the name).
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

  /// A small control (a switch) that sits beside the name on a phone.
  final bool controlBeside;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final small = TextStyle(color: context.tc.muted, fontSize: 12.5);
    final heading = Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: context.tc.ink,
        fontSize: 15,
      ),
    );
    final explanation = [
      Text(help, style: TextStyle(color: context.tc.muted, height: 1.4)),
      const SizedBox(height: 6),
      _Note(Icons.ads_click, l.settingsAffects(area: affects), small),
      _Note(Icons.schedule, l.settingsApplies(when: when), small),
    ];
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= 600;
        if (wide) {
          return Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heading,
                      const SizedBox(height: 4),
                      ...explanation,
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  flex: 4,
                  child: Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: controlBeside
                        ? control
                        : ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 300),
                            child: control,
                          ),
                  ),
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 14),
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
              ...explanation,
              if (!controlBeside) ...[const SizedBox(height: 12), control],
            ],
          ),
        );
      },
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
          child: Icon(icon, size: 14, color: context.tc.muted),
        ),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: style)),
      ],
    ),
  );
}

/// An on/off setting: [SettingTile] with a switch.
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

/// A number field with its range check: an error under it while the text
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
