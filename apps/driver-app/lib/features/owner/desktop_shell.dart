import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../app/workspaces.dart';
import '../account/account_security_screen.dart';
import '../common/format.dart';
import '../common/language_picker.dart';
import '../workspaces/workspace_switcher.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'owner_text.dart';
import 'owner_widgets.dart';
import 'people_screens.dart';
import 'settings_screen.dart';
import 'settlements_screen.dart';
import 'trips/owner_trips_screen.dart';
import 'vehicles_screen.dart';

enum OwnerSection {
  dashboard,
  trips,
  vehicles,
  drivers,
  analytics,
  settlements,
  settings,
}

/// Owner mode on a desktop-sized screen (the web build): a sidebar with every
/// section, grouped, and the section's pages on the right. Each section keeps
/// its own page stack, so opening a trip or a vehicle stays inside the content
/// area and the sidebar never goes away.
class DesktopOwnerShell extends ConsumerStatefulWidget {
  const DesktopOwnerShell({super.key});

  @override
  ConsumerState<DesktopOwnerShell> createState() => _DesktopOwnerShellState();
}

class _DesktopOwnerShellState extends ConsumerState<DesktopOwnerShell> {
  var _section = OwnerSection.dashboard;

  /// Sections opened so far, built lazily and kept alive.
  final _opened = <OwnerSection>{OwnerSection.dashboard};
  final _navigators = {
    for (final s in OwnerSection.values) s: GlobalKey<NavigatorState>(),
  };

  void _open(OwnerSection section) {
    if (section == _section) {
      // Clicking the current section goes back to its first page.
      _navigators[section]!.currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() {
      _section = section;
      _opened.add(section);
    });
  }

  /// The logo and name: back to the dashboard's first page from anywhere.
  void _goHome() {
    _navigators[OwnerSection.dashboard]!.currentState?.popUntil(
      (r) => r.isFirst,
    );
    if (_section != OwnerSection.dashboard) _open(OwnerSection.dashboard);
  }

  Widget _root(OwnerSection section) => switch (section) {
    OwnerSection.dashboard => DashboardScreen(
      onOpenTrips: () => _open(OwnerSection.trips),
    ),
    OwnerSection.trips => const OwnerTripsScreen(),
    OwnerSection.vehicles => const VehiclesScreen(),
    OwnerSection.drivers => const DriversScreen(),
    OwnerSection.analytics => const AnalyticsScreen(),
    OwnerSection.settlements => const SettlementsScreen(),
    OwnerSection.settings => const SettingsScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final sections = OwnerSection.values;
    return Scaffold(
      key: const Key('owner-desktop'),
      body: Row(
        children: [
          _Sidebar(selected: _section, onOpen: _open, onHome: _goHome),
          Expanded(
            child: Theme(
              data: desktopContentTheme(Theme.of(context)),
              child: IndexedStack(
                index: sections.indexOf(_section),
                children: [
                  for (final s in sections)
                    if (_opened.contains(s))
                      // Hidden sections stay alive but their animations
                      // (e.g. the dashboard's background) stop.
                      TickerMode(
                        enabled: s == _section,
                        child: HeroControllerScope.none(
                          child: Navigator(
                            key: _navigators[s],
                            onGenerateRoute: (_) => MaterialPageRoute<void>(
                              builder: (_) => _root(s),
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Page headers on the desktop: white and left-aligned, like a web app, instead
/// of the phone's blue bar.
ThemeData desktopContentTheme(ThemeData base) => base.copyWith(
  appBarTheme: base.appBarTheme.copyWith(
    backgroundColor: Colors.white,
    foregroundColor: TaxcyColors.ink,
    centerTitle: false,
    toolbarHeight: 72,
    titleSpacing: 28,
    scrolledUnderElevation: 0,
    shape: const Border(bottom: BorderSide(color: TaxcyColors.border)),
    titleTextStyle: const TextStyle(
      color: TaxcyColors.blue950,
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    iconTheme: const IconThemeData(color: TaxcyColors.blue800),
    actionsIconTheme: const IconThemeData(color: TaxcyColors.blue800),
  ),
);

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.selected,
    required this.onOpen,
    required this.onHome,
  });

  final OwnerSection selected;
  final ValueChanged<OwnerSection> onOpen;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    Widget item(OwnerSection s, IconData icon, String label) => _NavItem(
      key: Key('side-${s.name}'),
      icon: icon,
      label: label,
      selected: s == selected,
      onTap: () => onOpen(s),
    );
    return Container(
      key: const Key('owner-sidebar'),
      width: 264,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [TaxcyColors.blue950, Color(0xFF0F1A3D)],
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Brand(onTap: onHome),
            const _FleetCard(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                children: [
                  _GroupLabel(l.navGroupOverview),
                  item(
                    OwnerSection.dashboard,
                    Icons.space_dashboard_outlined,
                    l.navDashboard,
                  ),
                  item(OwnerSection.trips, Icons.route, l.navTrips),
                  _GroupLabel(l.navGroupFleet),
                  item(
                    OwnerSection.vehicles,
                    Icons.directions_car_outlined,
                    l.vehicles,
                  ),
                  item(OwnerSection.drivers, Icons.badge_outlined, l.drivers),
                  item(OwnerSection.analytics, Icons.insights, l.analytics),
                  _GroupLabel(l.navGroupMoney),
                  item(
                    OwnerSection.settlements,
                    Icons.account_balance_wallet_outlined,
                    l.settlements,
                  ),
                  _GroupLabel(l.navGroupSetup),
                  item(
                    OwnerSection.settings,
                    Icons.settings_outlined,
                    l.settings,
                  ),
                ],
              ),
            ),
            const _AccountFooter(),
          ],
        ),
      ),
    );
  }
}

/// The logo and app name; clicking either goes to the dashboard.
class _Brand extends StatelessWidget {
  const _Brand({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
    child: Semantics(
      link: true,
      label: context.l10n.navDashboard,
      child: InkWell(
        key: const Key('side-brand'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          child: _brandRow(context),
        ),
      ),
    ),
  );

  Widget _brandRow(BuildContext context) => Row(
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.local_taxi,
          color: TaxcyColors.blue700,
          size: 22,
        ),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          context.l10n.appTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
    ],
  );
}

/// The fleet being managed and the user's role; opens the switcher when they
/// have other fleets or drive too.
class _FleetCard extends ConsumerWidget {
  const _FleetCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final session = ref.watch(authProvider).value;
    if (session == null) return const SizedBox.shrink();
    final canSwitch = workspacesFor(session).length > 1;
    final roles = session.roles.map((r) => roleLabel(l, r)).join(', ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Material(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: const Key('switch-workspace'),
          borderRadius: BorderRadius.circular(12),
          onTap: canSwitch ? () => showWorkspaceSwitcher(context, ref) : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: TaxcyColors.blue600,
                  foregroundColor: Colors.white,
                  child: Text(
                    initials(session.activeMembership?.orgName ?? ''),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.activeMembership?.orgName ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        roles,
                        style: const TextStyle(
                          color: TaxcyColors.blue200,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canSwitch)
                  Tooltip(
                    message: l.switchWorkspace,
                    child: const Icon(
                      Icons.unfold_more,
                      color: TaxcyColors.blue200,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 16, 12, 6),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: TaxcyColors.blue300,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : const Color(0xFFC7D6F5);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: selected ? TaxcyColors.blue700 : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          hoverColor: Colors.white.withValues(alpha: 0.07),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: fg,
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
}

/// Who's signed in, with language, account security and sign out.
class _AccountFooter extends ConsumerWidget {
  const _AccountFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final session = ref.watch(authProvider).value;
    if (session == null) return const SizedBox.shrink();
    final name = session.name ?? formatPhone(session.phone);
    const iconColor = TaxcyColors.blue200;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            foregroundColor: Colors.white,
            child: Text(
              initials(name),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  formatPhone(session.phone),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(color: iconColor, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l.language,
            icon: const Icon(Icons.translate, color: iconColor, size: 20),
            onPressed: () => showLanguagePicker(context, ref),
          ),
          IconButton(
            key: const Key('more-account-security'),
            tooltip: l.accountSecurity,
            icon: const Icon(Icons.lock_outline, color: iconColor, size: 20),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => const Dialog(
                clipBehavior: Clip.antiAlias,
                child: SizedBox(
                  width: 520,
                  height: 640,
                  child: AccountSecurityScreen(),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: l.signOut,
            icon: const Icon(Icons.logout, color: iconColor, size: 20),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}
