import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/preferences.dart';
import 'format.dart';

/// The name of a theme choice, e.g. "Dark".
String themeModeLabel(BuildContext context, ThemeMode mode) {
  final l = context.l10n;
  return switch (mode) {
    ThemeMode.system => l.themeSystem,
    ThemeMode.light => l.themeLight,
    ThemeMode.dark => l.themeDark,
  };
}

/// Lets the user pick light, dark, or the phone's setting; saved on the phone.
Future<void> showThemePicker(BuildContext context, WidgetRef ref) async {
  final current = ref.read(themeModeProvider);
  final picked = await showDialog<ThemeMode>(
    context: context,
    builder: (dialog) => SimpleDialog(
      title: Text(dialog.l10n.appearance),
      children: [
        for (final mode in ThemeMode.values)
          ListTile(
            key: Key('theme-${mode.name}'),
            leading: Icon(
              mode == current
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
            ),
            title: Text(themeModeLabel(dialog, mode)),
            onTap: () => Navigator.of(dialog).pop(mode),
          ),
      ],
    ),
  );
  if (picked == null) return;
  ref.read(themeModeProvider.notifier).set(picked);
}

/// A sun or moon in the app bar, beside the alerts bell: one tap switches
/// between light and dark (from whatever is showing now, the phone's setting
/// included). Settings → Appearance goes back to the phone's setting.
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      key: const Key('theme-toggle'),
      tooltip: dark ? l.switchToLight : l.switchToDark,
      icon: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
      onPressed: () => ref
          .read(themeModeProvider.notifier)
          .set(dark ? ThemeMode.light : ThemeMode.dark),
    );
  }
}
