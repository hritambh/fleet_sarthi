import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/workspaces.dart';
import '../../app/theme.dart';
import '../account/account_security_screen.dart';
import '../common/format.dart';
import '../common/language_picker.dart';
import 'dashboard_screen.dart';
import 'desktop_shell.dart';
import 'alerts_inbox.dart';
import 'analytics_screen.dart';
import 'owner_text.dart';
import 'owner_widgets.dart';
import 'people_screens.dart';
import 'settings_screen.dart';
import 'settlements_screen.dart';
import 'trips/owner_trips_screen.dart';
import 'vehicles_screen.dart';
import '../workspaces/workspace_switcher.dart';

/// Owner mode: Dashboard / Trips / More, with alerts and review behind the
/// bell in each page header. A bottom navigation bar on phones, a side rail on
/// tablets, and on a desktop-sized screen (the web build on a laptop) the
/// [DesktopOwnerShell] with every section in a sidebar.
class OwnerShell extends ConsumerStatefulWidget {
  const OwnerShell({super.key});

  @override
  ConsumerState<OwnerShell> createState() => _OwnerShellState();
}

class _OwnerShellState extends ConsumerState<OwnerShell> {
  int _tab = 0;

  void _open(int tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    if (isDesktop(context)) return const DesktopOwnerShell();
    final l = context.l10n;
    final destinations = [
      (Icons.dashboard_outlined, l.navDashboard),
      (Icons.route, l.navTrips),
      (Icons.menu, l.navMore),
    ];
    final body = IndexedStack(
      index: _tab,
      children: [
        DashboardScreen(onOpenTrips: () => _open(1)),
        const OwnerTripsScreen(),
        const MoreScreen(),
      ],
    );
    final wide = MediaQuery.sizeOf(context).width >= 840;
    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              key: const Key('owner-rail'),
              selectedIndex: _tab,
              onDestinationSelected: _open,
              labelType: NavigationRailLabelType.all,
              backgroundColor: Colors.white,
              indicatorColor: TaxcyColors.blue100,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Icon(Icons.local_taxi, color: TaxcyColors.blue700),
              ),
              destinations: [
                for (final (icon, label) in destinations)
                  NavigationRailDestination(
                    icon: Icon(icon),
                    label: Text(label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        key: const Key('owner-nav'),
        selectedIndex: _tab,
        onDestinationSelected: _open,
        backgroundColor: Colors.white,
        indicatorColor: TaxcyColors.blue100,
        destinations: [
          for (final (icon, label) in destinations)
            NavigationDestination(icon: Icon(icon), label: label),
        ],
      ),
    );
  }
}

/// Everything else: fleet, money, settings, language, mode switch, sign out.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final session = ref.watch(authProvider).value;
    Widget item(IconData icon, String title, Widget screen, {Key? key}) =>
        ListTile(
          key: key,
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => openScreen<void>(context, screen),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l.navMore), actions: const [AlertsBell()]),
      body: ListView(
        children: [
          PageWidth(
            child: Column(
              children: [
                if (session != null)
                  ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(session.activeMembership?.orgName ?? ''),
                    subtitle: Text(
                      l.signedInAs(
                        name: session.name ?? formatPhone(session.phone),
                        roles: session.roles
                            .map((r) => roleLabel(l, r))
                            .join(', '),
                      ),
                    ),
                  ),
                const Divider(),
                item(
                  Icons.directions_car,
                  l.vehicles,
                  const VehiclesScreen(),
                  key: const Key('more-vehicles'),
                ),
                item(
                  Icons.badge,
                  l.drivers,
                  const DriversScreen(),
                  key: const Key('more-drivers'),
                ),
                item(
                  Icons.insights,
                  l.analytics,
                  const AnalyticsScreen(),
                  key: const Key('more-analytics'),
                ),
                item(
                  Icons.account_balance_wallet,
                  l.settlements,
                  const SettlementsScreen(),
                  key: const Key('more-settlements'),
                ),
                item(
                  Icons.settings,
                  l.settings,
                  const SettingsScreen(),
                  key: const Key('more-settings'),
                ),
                item(
                  Icons.lock_outline,
                  l.accountSecurity,
                  const AccountSecurityScreen(),
                  key: const Key('more-account-security'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.translate),
                  title: Text(l.language),
                  onTap: () => showLanguagePicker(context, ref),
                ),
                if (session != null && workspacesFor(session).length > 1)
                  ListTile(
                    key: const Key('switch-workspace'),
                    leading: const Icon(Icons.swap_horiz),
                    title: Text(l.switchWorkspace),
                    onTap: () => showWorkspaceSwitcher(context, ref),
                  ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(l.signOut),
                  onTap: () => ref.read(authProvider.notifier).signOut(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      'v$appVersion',
                      key: const Key('more-version'),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: TaxcyColors.muted,
                      ),
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
