import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/repositories/trips_repository.dart';
import '../../l10n/app_localizations.dart';
import '../common/errors.dart';
import '../common/format.dart';
import '../common/widgets.dart';
import '../driver/driver_providers.dart';
import 'driver_home.dart';
import 'driver_summary.dart';

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
    // New trips and fuel fills start from the quick actions on the home view;
    // fleet, language, security and sign out are on the Profile tab.
    return Scaffold(
      appBar: AppBar(title: Text(l.myTrips)),
      body: Column(
        children: [
          const SyncStatusBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () {
                ref.invalidate(myDriverProvider);
                return ref.read(syncEngineProvider).syncNow();
              },
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
