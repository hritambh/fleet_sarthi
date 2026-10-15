import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/owner/trips/owner_trips_screen.dart';

import 'support/fakes.dart';

Trip trip(String id, DateTime start) =>
    Trip.fromJson(tripJson(id: id, scheduledStartAt: start));

void main() {
  test('trips are grouped by the IST day they start, in list order', () {
    // 19:00 UTC on the 11th is 00:30 IST on the 12th.
    final groups = groupTripsByDay([
      trip('a', DateTime.utc(2026, 10, 11, 19)),
      trip('b', DateTime.utc(2026, 10, 12, 6)),
      trip('c', DateTime.utc(2026, 10, 10, 6)),
    ]);
    expect(groups.map((g) => g.$1), ['2026-10-12', '2026-10-10']);
    expect(groups[0].$2.map((t) => t.id), contains('a'));
    expect(groups[0].$2, hasLength(2));
    expect(groups[1].$2, hasLength(1));
  });

  test('no trips, no groups', () {
    expect(groupTripsByDay([]), isEmpty);
  });
}
