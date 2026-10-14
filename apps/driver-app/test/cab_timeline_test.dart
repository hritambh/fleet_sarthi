import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/json.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/owner/cab_timeline.dart';

import 'support/fakes.dart';
import 'support/owner_fakes.dart';

/// 10 Oct 2026 00:00 IST.
final dayStart = DateTime.utc(2026, 10, 9, 18, 30);

/// [hours] after IST midnight.
DateTime ist(double hours) =>
    dayStart.add(Duration(minutes: (hours * 60).round()));

Trip trip({
  String status = 'assigned',
  required double from,
  required double to,
  double? startedAt,
  double? endedAt,
  String vehicle = vehicleId,
  bool noVehicle = false,
}) {
  final json = tripJson(status: status, scheduledStartAt: ist(from));
  return Trip.fromJson(<String, Object?>{
    ...json,
    'scheduledEndAt': ist(to).toIso8601String(),
    'startedAt': startedAt == null ? null : ist(startedAt).toIso8601String(),
    'endedAt': endedAt == null ? null : ist(endedAt).toIso8601String(),
    'vehicle': noVehicle ? null : {...json.obj('vehicle'), 'id': vehicle},
  });
}

final cars = [
  Vehicle.fromJson(vehicleJson(id: vehicle2Id, reg: 'MH12CD5678')),
  Vehicle.fromJson(vehicleJson()),
  Vehicle.fromJson(
    vehicleJson(
      id: '0199c7a2-0000-7000-8000-0000000000ac',
      reg: 'MH01AA0001',
      status: 'inactive',
    ),
  ),
];

List<CabDay> days(List<Trip> trips, {double nowHours = 12}) => cabDays(
  vehicles: cars,
  trips: trips,
  dayStart: dayStart,
  now: ist(nowHours),
);

void main() {
  test('an assigned trip holds its cab for the scheduled window', () {
    final d = days([trip(from: 6, to: 12)]).first;
    expect(d.registrationNo, 'MH12AB1234');
    expect(d.busy, [(from: 0.25, to: 0.5)]);
    expect(d.busyShare, 0.25);
  });

  test('a finished trip uses the actual start and end', () {
    final d = days([
      trip(status: 'ended', from: 6, to: 12, startedAt: 7, endedAt: 9),
    ]).first;
    expect(d.busy, [(from: 7 / 24, to: 9 / 24)]);
  });

  test('a running trip past its scheduled end holds the cab until now', () {
    final d = days([
      trip(status: 'started', from: 6, to: 9, startedAt: 6),
    ], nowHours: 12).first;
    expect(d.busy, [(from: 0.25, to: 0.5)]);
  });

  test('unassigned, cancelled and vehicle-less trips hold nothing', () {
    final d = days([
      trip(status: 'created', from: 1, to: 2),
      trip(status: 'cancelled', from: 3, to: 4),
      trip(from: 5, to: 6, noVehicle: true),
    ]).first;
    expect(d.busy, isEmpty);
  });

  test('overnight trips are clipped to the day, overlaps merged', () {
    final d = days([
      trip(from: -3, to: 2),
      trip(from: 1, to: 3),
      trip(from: 22, to: 27),
    ]).first;
    expect(d.busy, [(from: 0.0, to: 3 / 24), (from: 22 / 24, to: 1.0)]);
  });

  test('active cabs first, by registration; inactive last', () {
    expect(days(const []).map((d) => d.registrationNo), [
      'MH12AB1234',
      'MH12CD5678',
      'MH01AA0001',
    ]);
  });

  test('free share counts active cabs only', () {
    // Cab 1 busy 12 h, cab 2 free all day, the inactive cab ignored.
    expect(freeShare(days([trip(from: 0, to: 12)])), 0.75);
    expect(freeShare(const []), isNull);
  });
}
