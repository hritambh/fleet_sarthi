import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/preferences.dart';
import '../../app/theme.dart';
import '../account/account_security_screen.dart';
import '../common/format.dart';
import '../common/language_picker.dart';
import 'alerts_inbox.dart';
import 'owner_widgets.dart';
import 'settings/settings_pages.dart';

/// The settings hub: one page per category, each explaining what its settings
/// change. "Your fleet" holds the fleet-wide settings (owner edits, managers
/// read); "You" holds this person's own (language, account security).
/// Details: docs/plans/2026-10-16-settings-hub.md.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final isOwner = ref.watch(isOwnerProvider);
    final locale = ref.watch(localeProvider);
    final fleet = <_Category>[
      (
        key: const Key('settings-general'),
        icon: Icons.storefront_outlined,
        title: l.settingsGeneral,
        description: l.settingsGeneralDesc,
        open: () => openScreen<void>(context, const GeneralSettingsScreen()),
      ),
      (
        key: const Key('settings-trips'),
        icon: Icons.route_outlined,
        title: l.settingsTrips,
        description: l.settingsTripsDesc,
        open: () => openScreen<void>(context, const TripRulesScreen()),
      ),
      (
        key: const Key('settings-fuel'),
        icon: Icons.local_gas_station_outlined,
        title: l.settingsFuel,
        description: l.settingsFuelDesc,
        open: () => openScreen<void>(context, const FuelRulesScreen()),
      ),
      (
        key: const Key('settings-reminders'),
        icon: Icons.notifications_active_outlined,
        title: l.settingsReminders,
        description: l.settingsRemindersDesc,
        open: () => openScreen<void>(context, const RemindersScreen()),
      ),
      (
        key: const Key('settings-pay'),
        icon: Icons.payments_outlined,
        title: l.defaultDriverPay,
        description: l.settingsPayDesc,
        open: () => openScreen<void>(context, const PaySettingsScreen()),
      ),
      (
        key: const Key('settings-team'),
        icon: Icons.group_outlined,
        title: l.settingsTeam,
        description: l.settingsTeamDesc,
        open: () => openScreen<void>(context, const TeamSettingsScreen()),
      ),
    ];
    final you = <_Category>[
      (
        key: const Key('settings-language'),
        icon: Icons.translate,
        title: l.language,
        description: locale == null
            ? l.languageDevice
            : languageNames[locale.languageCode] ?? locale.languageCode,
        open: () => showLanguagePicker(context, ref),
      ),
      (
        key: const Key('settings-account-security'),
        icon: Icons.lock_outline,
        title: l.accountSecurity,
        description: l.settingsSecurityDesc,
        open: () => openScreen<void>(context, const AccountSecurityScreen()),
      ),
    ];
    final desktop = isDesktop(context);
    Widget group(String title, List<_Category> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: TaxcyColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        if (desktop)
          CardGrid(
            minWidth: 280,
            children: [for (final c in items) _CategoryCard(c)],
          )
        else
          Card(
            child: Column(
              children: [
                for (final (i, c) in items.indexed) ...[
                  if (i > 0) const Divider(height: 1, indent: 56),
                  _CategoryTile(c),
                ],
              ],
            ),
          ),
      ],
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.settings), actions: const [AlertsBell()]),
      body: ListView(
        padding: desktop
            ? const EdgeInsets.fromLTRB(28, 24, 28, 24)
            : const EdgeInsets.fromLTRB(12, 8, 12, 24),
        children: [
          for (final child in [
            Text(
              l.settingsIntro,
              style: const TextStyle(color: TaxcyColors.muted),
            ),
            if (!isOwner)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l.settingsOwnerOnly,
                  key: const Key('settings-owner-only'),
                  style: const TextStyle(
                    color: TaxcyColors.blue800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            group(l.settingsGroupFleet, fleet),
            group(l.settingsGroupYou, you),
          ])
            PageWidth(child: child),
        ],
      ),
    );
  }
}

typedef _Category = ({
  Key key,
  IconData icon,
  String title,
  String description,
  VoidCallback open,
});

/// A category as a list row (phones and tablets).
class _CategoryTile extends StatelessWidget {
  const _CategoryTile(this.c);
  final _Category c;

  @override
  Widget build(BuildContext context) => ListTile(
    key: c.key,
    leading: _CategoryIcon(c.icon),
    title: Text(c.title),
    subtitle: Text(c.description),
    trailing: const Icon(Icons.chevron_right),
    onTap: c.open,
  );
}

/// A category as a card (desktop).
class _CategoryCard extends StatelessWidget {
  const _CategoryCard(this.c);
  final _Category c;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      key: c.key,
      onTap: c.open,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _CategoryIcon(c.icon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    c.description,
                    style: const TextStyle(color: TaxcyColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: TaxcyColors.muted),
          ],
        ),
      ),
    ),
  );
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon(this.icon);
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      color: TaxcyColors.blue50,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: TaxcyColors.blue700, size: 22),
  );
}

/// "30, 7, 1" → [30, 7, 1]; null when any part isn't a whole number.
List<int>? parseDayList(String text) {
  final parts = text.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty);
  final days = [for (final p in parts) int.tryParse(p)];
  return days.contains(null) ? null : days.whereType<int>().toList();
}
