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
import 'settings/settings_widgets.dart';

/// The settings hub: one page per category, each explaining what its settings
/// change. "Your fleet" holds the fleet-wide settings (owner edits, managers
/// read); "You" holds this person's own (language, account security).
///
/// On a phone or tablet it's a list that opens each page. On the desktop it's
/// a settings column (categories under group headings) beside the chosen page;
/// switching pages with unsaved changes asks first.
/// Details: docs/plans/2026-10-16-settings-hub.md.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// The page shown on the desktop, by its category key.
  var _selected = 'settings-general';

  /// Whether the shown page has unsaved edits (it reports through SettingsHost).
  final _dirty = ValueNotifier(false);

  @override
  void dispose() {
    _dirty.dispose();
    super.dispose();
  }

  Future<void> _select(String key) async {
    if (key == _selected) return;
    if (_dirty.value && !await confirmDiscardSettings(context)) return;
    _dirty.value = false;
    setState(() => _selected = key);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final isOwner = ref.watch(isOwnerProvider);
    final locale = ref.watch(localeProvider);
    final desktop = isDesktop(context);
    // On the desktop a category shows its page beside the column; on a phone
    // it opens the page.
    VoidCallback open(String key, Widget page) =>
        desktop ? () => _select(key) : () => openScreen<void>(context, page);
    final pages = <String, Widget>{
      'settings-general': const GeneralSettingsScreen(),
      'settings-trips': const TripRulesScreen(),
      'settings-fuel': const FuelRulesScreen(),
      'settings-reminders': const RemindersScreen(),
      'settings-pay': const PaySettingsScreen(),
      'settings-team': const TeamSettingsScreen(),
      'settings-account-security': const AccountSecurityScreen(),
    };
    _Category category(
      String key,
      IconData icon,
      String title,
      String description,
    ) => (
      key: Key(key),
      icon: icon,
      title: title,
      description: description,
      open: open(key, pages[key]!),
    );
    final fleet = <_Category>[
      category(
        'settings-general',
        Icons.tune,
        l.settingsGeneral,
        l.settingsGeneralDesc,
      ),
      category(
        'settings-trips',
        Icons.route_outlined,
        l.settingsTrips,
        l.settingsTripsDesc,
      ),
      category(
        'settings-fuel',
        Icons.local_gas_station_outlined,
        l.settingsFuel,
        l.settingsFuelDesc,
      ),
      category(
        'settings-reminders',
        Icons.notifications_active_outlined,
        l.settingsReminders,
        l.settingsRemindersDesc,
      ),
      category(
        'settings-pay',
        Icons.payments_outlined,
        l.defaultDriverPay,
        l.settingsPayDesc,
      ),
      category(
        'settings-team',
        Icons.group_outlined,
        l.settingsTeam,
        l.settingsTeamDesc,
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
        // A picker, not a page, on every layout.
        open: () => showLanguagePicker(context, ref),
      ),
      category(
        'settings-account-security',
        Icons.lock_outline,
        l.accountSecurity,
        l.settingsSecurityDesc,
      ),
    ];

    if (desktop) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: Text(l.settings), actions: const [AlertsBell()]),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SettingsNav(
              groups: [
                (l.settingsGroupFleet, fleet),
                (l.settingsGroupYou, you),
              ],
              selected: _selected,
              note: isOwner ? null : l.settingsOwnerOnly,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: SettingsHost(
                dirty: _dirty,
                child: KeyedSubtree(
                  key: ValueKey(_selected),
                  child: pages[_selected]!,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget group(String title, List<_Category> items) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GroupLabel(title),
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
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
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

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(
    this.text, {
    this.padding = const EdgeInsets.fromLTRB(4, 16, 4, 8),
  });
  final String text;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: padding,
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: TaxcyColors.muted,
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    ),
  );
}

/// The desktop settings column: categories under their group headings, the
/// shown page highlighted.
class _SettingsNav extends StatelessWidget {
  const _SettingsNav({required this.groups, required this.selected, this.note});

  final List<(String, List<_Category>)> groups;
  final String selected;

  /// For managers: settings are the owner's.
  final String? note;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('settings-nav'),
    width: 248,
    color: TaxcyColors.background,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        for (final (title, items) in groups) ...[
          _GroupLabel(title, padding: const EdgeInsets.fromLTRB(10, 12, 10, 6)),
          for (final c in items)
            _NavItem(
              c,
              selected: (c.key as ValueKey<String>).value == selected,
            ),
        ],
        if (note case final note?)
          Padding(
            key: const Key('settings-owner-only'),
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
            child: Text(
              note,
              style: const TextStyle(color: TaxcyColors.muted, fontSize: 12.5),
            ),
          ),
      ],
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem(this.c, {required this.selected});
  final _Category c;
  final bool selected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Material(
      color: selected ? TaxcyColors.blue100 : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        key: c.key,
        borderRadius: BorderRadius.circular(8),
        onTap: c.open,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Icon(
                c.icon,
                size: 18,
                color: selected ? TaxcyColors.blue800 : TaxcyColors.muted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  c.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? TaxcyColors.blue950 : TaxcyColors.ink,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
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
