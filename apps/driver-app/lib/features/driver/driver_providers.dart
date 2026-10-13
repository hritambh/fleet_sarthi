import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/api/models.dart';
import '../../core/api/owner_models.dart';

/// The signed-in driver's own record (name, phone, cabs they can drive).
final myDriverProvider = FutureProvider.autoDispose<Driver>(
  (ref) => ref.watch(meApiProvider).driver(),
);

/// The driver's current documents, including ones waiting for approval.
final myDocumentsProvider = FutureProvider.autoDispose<List<FleetDocument>>(
  (ref) => ref.watch(meApiProvider).documents(),
);

/// A window of time: trips whose scheduled window overlaps [from, to).
typedef TripRange = ({DateTime from, DateTime to});

/// The driver's trips in a window, any status (past trips, the calendar).
final myTripsBetweenProvider = FutureProvider.autoDispose
    .family<List<Trip>, TripRange>(
      (ref, range) =>
          ref.watch(meApiProvider).tripsBetween(range.from, range.to),
    );
