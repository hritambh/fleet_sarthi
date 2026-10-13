import 'package:flutter/material.dart';

import '../common/format.dart';
import '../owner/owner_widgets.dart';
import '../trips/trips_screen.dart';
import 'driver_documents_screen.dart';
import 'driver_profile_screen.dart';
import 'driver_trips_screen.dart';

/// The driver app: Home (today, the next trip, quick actions), Trips
/// (assigned, past, schedule), Documents and Profile. Bottom tabs on a phone,
/// a side rail on a wide screen.
class DriverShell extends StatefulWidget {
  const DriverShell({super.key});

  @override
  State<DriverShell> createState() => _DriverShellState();
}

class _DriverShellState extends State<DriverShell> {
  var _index = 0;

  /// Built the first time each tab is opened, then kept.
  final _opened = <int>{0};

  static const _pages = [
    TripsScreen(),
    DriverTripsScreen(),
    DriverDocumentsScreen(),
    DriverProfileScreen(),
  ];

  void _select(int i) => setState(() {
    _index = i;
    _opened.add(i);
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final destinations = [
      (Icons.home_outlined, Icons.home, l.navHome, 'home'),
      (Icons.route_outlined, Icons.route, l.navTrips, 'trips'),
      (Icons.description_outlined, Icons.description, l.navMyDocuments, 'docs'),
      (Icons.person_outline, Icons.person, l.navProfile, 'profile'),
    ];
    final body = IndexedStack(
      index: _index,
      children: [
        for (final (i, page) in _pages.indexed)
          _opened.contains(i) ? page : const SizedBox.shrink(),
      ],
    );
    if (isDesktop(context)) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              key: const Key('driver-nav'),
              selectedIndex: _index,
              onDestinationSelected: _select,
              labelType: NavigationRailLabelType.all,
              destinations: [
                for (final (icon, selected, label, id) in destinations)
                  NavigationRailDestination(
                    icon: Icon(icon, key: Key('driver-nav-$id')),
                    selectedIcon: Icon(selected),
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
        key: const Key('driver-nav'),
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: [
          for (final (icon, selected, label, id) in destinations)
            NavigationDestination(
              icon: Icon(icon, key: Key('driver-nav-$id')),
              selectedIcon: Icon(selected),
              label: label,
            ),
        ],
      ),
    );
  }
}
