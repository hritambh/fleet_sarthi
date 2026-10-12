import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/repositories/trips_repository.dart';
import '../../l10n/app_localizations.dart';
import '../account/account_security_screen.dart';
import '../common/errors.dart';
import '../common/format.dart';
import '../common/language_picker.dart';
import '../common/widgets.dart';
import '../fuel/fuel_fill_screen.dart';
import 'driver_home.dart';
import 'driver_summary.dart';
import 'new_trip_screen.dart';
import '../workspaces/workspace_switcher.dart';

enum TripGroup { onTheRoad, today, upcoming, recent }

String tripGroupLabel(AppLocalizations l, TripGroup group) => switch (group) {
  TripGroup.onTheRoad => l.groupOnTheRoad,
  TripGroup.today => l.groupToday,
  TripGroup.upcoming => l.groupUpcoming,
  TripGroup.recent => l.groupRecent,
};

/// Groups trips the way a driver thinks about them.
Map<TripGroup, List<TripView>> groupTrips(
  List<TripView> trips, {
  DateTime? now,
}) {
  final today = (now ?? DateTime.now()).toLocal();
  final startOfToday = DateTime(today.year, today.month, today.day);
  final startOfTomorrow = startOfToday.add(const Duration(days: 1));
  final groups = {for (final g in TripGroup.values) g: <TripView>[]};
  for (final view in trips) {
    final t = view.trip;
    final at = t.scheduledStartAt.toLocal();
    if (t.status == 'started') {
      groups[TripGroup.onTheRoad]!.add(view);
    } else if (t.status == 'assigned' && at.isBefore(startOfTomorrow)) {
      groups[TripGroup.today]!.add(view);
    } else if (t.status == 'assigned' || t.status == 'created') {
      groups[TripGroup.upcoming]!.add(view);
    } else {
      groups[TripGroup.recent]!.add(view);
    }
  }
  groups[TripGroup.recent]!.sort(
    (a, b) => b.trip.scheduledStartAt.compareTo(a.trip.scheduledStartAt),
  );
  groups.removeWhere((_, list) => list.isEmpty);
  return groups;
}

class TripsScreen extends ConsumerWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trips = ref.watch(tripsProvider);
    final l = context.l10n;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('new-trip'),
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewTripScreen())),
        icon: const Icon(Icons.add),
        label: Text(l.newTrip),
      ),
      appBar: AppBar(
        title: Text(l.myTrips),
        actions: [
          IconButton(
            tooltip: l.logFuel,
            icon: const Icon(Icons.local_gas_station),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const FuelFillScreen()),
            ),
          ),
          PopupMenuButton<String>(
            key: const Key('driver-menu'),
            onSelected: (value) => switch (value) {
              'workspace' => showWorkspaceSwitcher(context, ref),
              'language' => showLanguagePicker(context, ref),
              'security' => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AccountSecurityScreen(),
                ),
              ),
              'signout' => ref.read(authProvider.notifier).signOut(),
              _ => null,
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                key: const Key('switch-workspace'),
                value: 'workspace',
                child: Text(l.switchWorkspace),
              ),
              PopupMenuItem(value: 'language', child: Text(l.language)),
              PopupMenuItem(
                key: const Key('driver-account-security'),
                value: 'security',
                child: Text(l.accountSecurity),
              ),
              PopupMenuItem(value: 'signout', child: Text(l.signOut)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          const SyncStatusBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(syncEngineProvider).syncNow(),
              child: trips.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(errorText(l, error)),
                    ),
                  ],
                ),
                data: (list) {
                  final groups = groupTrips(list);
                  final summary = summariseDriverDay(list);
                  final l = context.l10n;
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 96),
                    children: [
                      // A readable column on a wide screen (the web app).
                      for (final child in [
                        const DriverHeader(),
                        if (summary.onTheRoad != null)
                          ActiveTripCard(summary.onTheRoad!),
                        if (summary.next != null) NextTripCard(summary.next!),
                        DriverStatsCard(
                          title: l.todayAtAGlance,
                          stats: summary.today,
                          showTotal: true,
                        ),
                        const DriverQuickActions(),
                        if (groups.isEmpty) const DriverEmptyState(),
                        for (final entry in groups.entries) ...[
                          TripSectionHeader(tripGroupLabel(l, entry.key)),
                          for (final view in entry.value) DriverTripTile(view),
                        ],
                        if (summary.week.tripsDone > 0)
                          DriverStatsCard(
                            title: l.lastSevenDays,
                            stats: summary.week,
                          ),
                      ])
                        Align(
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: child,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
