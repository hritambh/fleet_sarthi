import 'http_api.dart';
import 'json.dart';
import 'models.dart';
import 'owner_models.dart';

/// Filters for GET /trips. Each set means "any of these"; empty means all.
class TripFilter {
  const TripFilter({
    this.statuses = const {},
    this.driverIds = const {},
    this.vehicleIds = const {},
    this.from,
    this.to,
    this.overlapping = false,
    this.limit = 200,
  });

  final Set<String> statuses;
  final Set<String> driverIds;
  final Set<String> vehicleIds;
  final DateTime? from;
  final DateTime? to;

  /// Match trips whose scheduled window overlaps [from, to) instead of those
  /// starting inside it (calendars).
  final bool overlapping;
  final int limit;

  static String? _csv(Set<String> values) =>
      values.isEmpty ? null : (values.toList()..sort()).join(',');

  Map<String, String> toQuery() => {
    'status': ?_csv(statuses),
    'driverId': ?_csv(driverIds),
    'vehicleId': ?_csv(vehicleIds),
    if (from != null) 'from': from!.toUtc().toIso8601String(),
    if (to != null) 'to': to!.toUtc().toIso8601String(),
    if (overlapping) 'overlapping': 'true',
    'limit': '$limit',
  };

  static bool _same(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);

  @override
  bool operator ==(Object other) =>
      other is TripFilter &&
      _same(other.statuses, statuses) &&
      _same(other.driverIds, driverIds) &&
      _same(other.vehicleIds, vehicleIds) &&
      other.from == from &&
      other.to == to &&
      other.overlapping == overlapping &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(
    _csv(statuses),
    _csv(driverIds),
    _csv(vehicleIds),
    from,
    to,
    overlapping,
    limit,
  );
}

/// The staff (owner and manager) endpoints owner mode uses. Owner mode is
/// online-first: every screen calls these directly, so there's no outbox here.
/// Commands that need an Idempotency-Key take it from the caller, so retrying
/// the same dialog reuses it.
abstract class OwnerApi {
  // Trips
  Future<List<Trip>> trips(TripFilter filter);
  Future<Trip> trip(String id);
  Future<Trip> createTrip(JsonMap body);
  Future<List<TripEvent>> tripEvents(String id);
  Future<Trip> assign(
    String tripId, {
    required String vehicleId,
    required String driverId,
    required String idempotencyKey,
  });
  Future<Trip> unassign(String tripId, {required String idempotencyKey});
  Future<Trip> cancelTrip(
    String tripId, {
    required String reason,
    required String idempotencyKey,
  });
  Future<Trip> approveCancellation(
    String requestId, {
    required int cancellationFarePaise,
    required String idempotencyKey,
    String? note,
  });
  Future<Trip> rejectCancellation(
    String requestId, {
    required String note,
    required String idempotencyKey,
  });
  Future<Trip> addCharge(String tripId, JsonMap body);
  Future<Trip> voidCharge(String tripId, String chargeId);
  Future<Trip> addCollection(String tripId, JsonMap body);
  Future<TripRoute> tripRoute(String tripId);

  /// Vehicles and drivers already booked during [from, to), not counting
  /// [excludeTripId] (the trip being reassigned).
  Future<Availability> availability(
    DateTime from,
    DateTime to, {
    String? excludeTripId,
  });
  Future<DistanceCheck?> distanceCheck(String tripId);

  // Fleet
  Future<List<Vehicle>> vehicles({String? status});
  Future<Vehicle> vehicle(String id);
  Future<Vehicle> createVehicle(JsonMap body);
  Future<Vehicle> updateVehicle(String id, JsonMap body);

  /// Replaces the drivers who may drive vehicle [id].
  Future<Vehicle> setVehicleDrivers(String id, List<String> driverIds);
  Future<List<VehicleModel>> vehicleModels();

  /// Brands in the public vehicle catalogue, for the add-vehicle form.
  Future<List<CatalogBrand>> catalogBrands();

  /// Model names of one catalogue brand, by the id [catalogBrands] gave for it.
  Future<List<String>> catalogModels(String brandId);
  Future<List<Driver>> drivers({String? status});
  Future<Driver> inviteDriver({
    required String name,
    required String phone,
    List<String> vehicleIds = const [],
  });

  /// Replaces the vehicles driver [id] may drive.
  Future<Driver> setDriverVehicles(String id, List<String> vehicleIds);

  /// [unassignTrips] with status 'inactive': unassign their booked trips
  /// first (else DRIVER_HAS_TRIPS lists them).
  Future<Driver> updateDriver(
    String id, {
    String? name,
    String? status,
    bool unassignTrips = false,
  });

  /// Profile fields (photoMediaId, dateOfBirth, email, address,
  /// emergencyContactName, emergencyContactPhone); null clears one.
  Future<Driver> updateDriverProfile(String id, JsonMap body);
  Future<Driver> setDriverPayRule(String id, PayRule? payRule);
  Future<List<Member>> members();
  Future<Member> inviteManager({required String name, required String phone});
  Future<Member> removeManager(String memberId);
  Future<List<FleetDocument>> documents({
    String? vehicleId,
    String? driverId,
    int? expiringWithinDays,
  });
  Future<FleetDocument> createDocument(JsonMap body);
  Future<FleetDocument> renewDocument(String id, JsonMap body);

  /// A driver's upload: approve it (a renewal then replaces the old copy) or
  /// reject it with the reason the driver sees.
  Future<FleetDocument> approveDocument(String id);
  Future<FleetDocument> rejectDocument(String id, String note);

  // Settings
  Future<AuditSettings> auditSettings();
  Future<AuditSettings> updateAuditSettings(AuditSettings settings);
  Future<PayRule> defaultPayRule();
  Future<PayRule> updateDefaultPayRule(PayRule rule);

  // Fuel
  Future<List<FuelFill>> fuelFills({String? vehicleId, int limit = 100});
  Future<FuelFill> voidFuelFill(String id, {required String reason});
  Future<VehicleFuelAudit> vehicleAudit(String vehicleId);

  // Analytics
  /// Per-vehicle, per-day figures for [month] (YYYY-MM).
  Future<DailyAnalytics> dailyAnalytics(String month);

  /// The dashboard's headline figures for IST day [date] (YYYY-MM-DD).
  Future<DashboardSummary> dashboard(String date);

  // Alerts and review
  /// Each filter is one value or a comma-separated list (any of them).
  Future<List<Alert>> alerts({
    String? status,
    String? kind,
    String? severity,
    String? vehicleId,
    String? driverId,
    String? tripId,
    int limit = 200,
  });
  Future<AlertSummary> alertSummary();
  Future<Alert> updateAlert(String id, String status, {bool? falsePositive});
  Future<List<ReviewItem>> reviewItems({String? status});
  Future<ReviewItem> resolveReviewItem(
    String id,
    String resolution, {
    int? correctedValue,
  });

  // Settlements
  Future<List<SettlementSummary>> settlements(String date);
  Future<SettlementDetail> settlement(String date, String driverId);
  Future<SettlementDetail> settle(
    String date,
    String driverId, {
    required String idempotencyKey,
  });

  // Media
  Future<MediaUrl> mediaUrl(String mediaId);
}

/// [OwnerApi] over HTTP, sharing [HttpTaxcyApi]'s session handling.
class HttpOwnerApi implements OwnerApi {
  HttpOwnerApi(this._http);
  final HttpTaxcyApi _http;

  Future<JsonMap> _obj(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    String? idempotencyKey,
  }) async => asJsonMap(
    await _http.send(
      method,
      path,
      body: body,
      query: query,
      headers: {'Idempotency-Key': ?idempotencyKey},
    ),
  );

  Future<List<JsonMap>> _list(
    String path, [
    Map<String, String>? query,
  ]) async => jsonList(await _http.send('GET', path, query: query));

  @override
  Future<List<Trip>> trips(TripFilter filter) async =>
      (await _list('/trips', filter.toQuery())).map(Trip.fromJson).toList();

  @override
  Future<Trip> trip(String id) async =>
      Trip.fromJson(await _obj('GET', '/trips/$id'));

  @override
  Future<Trip> createTrip(JsonMap body) async =>
      Trip.fromJson(await _obj('POST', '/trips', body: body));

  @override
  Future<List<TripEvent>> tripEvents(String id) async =>
      (await _list('/trips/$id/events')).map(TripEvent.fromJson).toList();

  @override
  Future<Trip> assign(
    String tripId, {
    required String vehicleId,
    required String driverId,
    required String idempotencyKey,
  }) async => Trip.fromJson(
    await _obj(
      'POST',
      '/trips/$tripId/assign',
      body: {'vehicleId': vehicleId, 'driverId': driverId},
      idempotencyKey: idempotencyKey,
    ),
  );

  @override
  Future<Trip> unassign(
    String tripId, {
    required String idempotencyKey,
  }) async => Trip.fromJson(
    await _obj(
      'POST',
      '/trips/$tripId/unassign',
      idempotencyKey: idempotencyKey,
    ),
  );

  @override
  Future<Trip> cancelTrip(
    String tripId, {
    required String reason,
    required String idempotencyKey,
  }) async => Trip.fromJson(
    await _obj(
      'POST',
      '/trips/$tripId/cancel',
      body: {'reason': reason},
      idempotencyKey: idempotencyKey,
    ),
  );

  @override
  Future<Trip> approveCancellation(
    String requestId, {
    required int cancellationFarePaise,
    required String idempotencyKey,
    String? note,
  }) async => Trip.fromJson(
    await _obj(
      'POST',
      '/cancellation-requests/$requestId/approve',
      body: {'cancellationFarePaise': cancellationFarePaise, 'note': ?note},
      idempotencyKey: idempotencyKey,
    ),
  );

  @override
  Future<Trip> rejectCancellation(
    String requestId, {
    required String note,
    required String idempotencyKey,
  }) async => Trip.fromJson(
    await _obj(
      'POST',
      '/cancellation-requests/$requestId/reject',
      body: {'note': note},
      idempotencyKey: idempotencyKey,
    ),
  );

  @override
  Future<Trip> addCharge(String tripId, JsonMap body) async =>
      Trip.fromJson(await _obj('POST', '/trips/$tripId/charges', body: body));

  @override
  Future<Trip> voidCharge(String tripId, String chargeId) async =>
      Trip.fromJson(
        await _obj('POST', '/trips/$tripId/charges/$chargeId/void'),
      );

  @override
  Future<Trip> addCollection(String tripId, JsonMap body) async =>
      Trip.fromJson(
        await _obj('POST', '/trips/$tripId/collections', body: body),
      );

  @override
  Future<TripRoute> tripRoute(String tripId) async =>
      TripRoute.fromJson(await _obj('GET', '/trips/$tripId/route'));

  @override
  Future<Availability> availability(
    DateTime from,
    DateTime to, {
    String? excludeTripId,
  }) async => Availability.fromJson(
    await _obj(
      'GET',
      '/availability',
      query: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
        'excludeTripId': ?excludeTripId,
      },
    ),
  );

  @override
  Future<DistanceCheck?> distanceCheck(String tripId) async {
    final json = await _http.send('GET', '/trips/$tripId/distance-check');
    return json == null ? null : DistanceCheck.fromJson(asJsonMap(json));
  }

  @override
  Future<List<Vehicle>> vehicles({String? status}) async => (await _list(
    '/vehicles',
    {'status': ?status},
  )).map(Vehicle.fromJson).toList();

  @override
  Future<Vehicle> vehicle(String id) async =>
      Vehicle.fromJson(await _obj('GET', '/vehicles/$id'));

  @override
  Future<Vehicle> createVehicle(JsonMap body) async =>
      Vehicle.fromJson(await _obj('POST', '/vehicles', body: body));

  @override
  Future<Vehicle> updateVehicle(String id, JsonMap body) async =>
      Vehicle.fromJson(await _obj('PATCH', '/vehicles/$id', body: body));

  @override
  Future<Vehicle> setVehicleDrivers(String id, List<String> driverIds) async =>
      Vehicle.fromJson(
        await _obj(
          'PUT',
          '/vehicles/$id/drivers',
          body: {'driverIds': driverIds},
        ),
      );

  @override
  Future<List<VehicleModel>> vehicleModels() async =>
      (await _list('/vehicle-models')).map(VehicleModel.fromJson).toList();

  @override
  Future<List<CatalogBrand>> catalogBrands() async => (await _list(
    '/vehicle-catalog/brands',
  )).map(CatalogBrand.fromJson).toList();

  @override
  Future<List<String>> catalogModels(String brandId) async => (await _list(
    '/vehicle-catalog/models',
    {'brand': brandId},
  )).map((m) => m.str('name')).toList();

  @override
  Future<List<Driver>> drivers({String? status}) async => (await _list(
    '/drivers',
    {'status': ?status},
  )).map(Driver.fromJson).toList();

  @override
  Future<Driver> inviteDriver({
    required String name,
    required String phone,
    List<String> vehicleIds = const [],
  }) async => Driver.fromJson(
    await _obj(
      'POST',
      '/drivers',
      body: {
        'name': name,
        'phone': phone,
        if (vehicleIds.isNotEmpty) 'vehicleIds': vehicleIds,
      },
    ),
  );

  @override
  Future<Driver> setDriverVehicles(String id, List<String> vehicleIds) async =>
      Driver.fromJson(
        await _obj(
          'PUT',
          '/drivers/$id/vehicles',
          body: {'vehicleIds': vehicleIds},
        ),
      );

  @override
  Future<Driver> updateDriver(
    String id, {
    String? name,
    String? status,
    bool unassignTrips = false,
  }) async => Driver.fromJson(
    await _obj(
      'PATCH',
      '/drivers/$id',
      body: {
        'name': ?name,
        'status': ?status,
        if (unassignTrips) 'unassignTrips': true,
      },
    ),
  );

  @override
  Future<Driver> updateDriverProfile(String id, JsonMap body) async =>
      Driver.fromJson(await _obj('PATCH', '/drivers/$id', body: body));

  @override
  Future<Driver> setDriverPayRule(String id, PayRule? payRule) async =>
      Driver.fromJson(
        await _obj(
          'PUT',
          '/drivers/$id/pay-rule',
          body: {'payRule': payRule?.toJson()},
        ),
      );

  @override
  Future<List<Member>> members() async =>
      (await _list('/members')).map(Member.fromJson).toList();

  @override
  Future<Member> inviteManager({
    required String name,
    required String phone,
  }) async => Member.fromJson(
    await _obj(
      'POST',
      '/members/managers',
      body: {'name': name, 'phone': phone},
    ),
  );

  @override
  Future<Member> removeManager(String memberId) async =>
      Member.fromJson(await _obj('DELETE', '/members/$memberId/manager'));

  @override
  Future<List<FleetDocument>> documents({
    String? vehicleId,
    String? driverId,
    int? expiringWithinDays,
  }) async => (await _list('/documents', {
    'vehicleId': ?vehicleId,
    'driverId': ?driverId,
    if (expiringWithinDays != null) 'expiringWithinDays': '$expiringWithinDays',
  })).map(FleetDocument.fromJson).toList();

  @override
  Future<FleetDocument> createDocument(JsonMap body) async =>
      FleetDocument.fromJson(await _obj('POST', '/documents', body: body));

  @override
  Future<FleetDocument> renewDocument(String id, JsonMap body) async =>
      FleetDocument.fromJson(
        await _obj('POST', '/documents/$id/renew', body: body),
      );

  @override
  Future<FleetDocument> approveDocument(String id) async =>
      FleetDocument.fromJson(await _obj('POST', '/documents/$id/approve'));

  @override
  Future<FleetDocument> rejectDocument(String id, String note) async =>
      FleetDocument.fromJson(
        await _obj('POST', '/documents/$id/reject', body: {'note': note}),
      );

  @override
  Future<AuditSettings> auditSettings() async =>
      AuditSettings.fromJson(await _obj('GET', '/settings/audit'));

  @override
  Future<AuditSettings> updateAuditSettings(AuditSettings settings) async =>
      AuditSettings.fromJson(
        await _obj('PATCH', '/settings/audit', body: settings.toJson()),
      );

  @override
  Future<PayRule> defaultPayRule() async =>
      PayRule.fromJson(await _obj('GET', '/settings/driver-pay'));

  @override
  Future<PayRule> updateDefaultPayRule(PayRule rule) async => PayRule.fromJson(
    await _obj('PUT', '/settings/driver-pay', body: rule.toJson()),
  );

  @override
  Future<List<FuelFill>> fuelFills({
    String? vehicleId,
    int limit = 100,
  }) async => (await _list('/fuel-fills', {
    'vehicleId': ?vehicleId,
    'includeVoided': 'true',
    'limit': '$limit',
  })).map(FuelFill.fromJson).toList();

  @override
  Future<FuelFill> voidFuelFill(String id, {required String reason}) async =>
      FuelFill.fromJson(
        await _obj('POST', '/fuel-fills/$id/void', body: {'reason': reason}),
      );

  @override
  Future<VehicleFuelAudit> vehicleAudit(String vehicleId) async =>
      VehicleFuelAudit.fromJson(
        await _obj('GET', '/vehicles/$vehicleId/fuel-cycles'),
      );

  @override
  Future<List<Alert>> alerts({
    String? status,
    String? kind,
    String? severity,
    String? vehicleId,
    String? driverId,
    String? tripId,
    int limit = 200,
  }) async => (await _list('/alerts', {
    'status': ?status,
    'kind': ?kind,
    'severity': ?severity,
    'vehicleId': ?vehicleId,
    'driverId': ?driverId,
    'tripId': ?tripId,
    'limit': '$limit',
  })).map(Alert.fromJson).toList();

  @override
  Future<DailyAnalytics> dailyAnalytics(String month) async =>
      DailyAnalytics.fromJson(
        await _obj('GET', '/analytics/daily', query: {'month': month}),
      );

  @override
  Future<DashboardSummary> dashboard(String date) async =>
      DashboardSummary.fromJson(
        await _obj('GET', '/analytics/dashboard', query: {'date': date}),
      );

  @override
  Future<AlertSummary> alertSummary() async =>
      AlertSummary.fromJson(await _obj('GET', '/alerts/summary'));

  @override
  Future<Alert> updateAlert(
    String id,
    String status, {
    bool? falsePositive,
  }) async => Alert.fromJson(
    await _obj(
      'PATCH',
      '/alerts/$id',
      body: {'status': status, 'falsePositive': ?falsePositive},
    ),
  );

  @override
  Future<List<ReviewItem>> reviewItems({String? status}) async => (await _list(
    '/review-items',
    {'status': ?status, 'limit': '200'},
  )).map(ReviewItem.fromJson).toList();

  @override
  Future<ReviewItem> resolveReviewItem(
    String id,
    String resolution, {
    int? correctedValue,
  }) async => ReviewItem.fromJson(
    await _obj(
      'POST',
      '/review-items/$id/resolve',
      body: {'resolution': resolution, 'correctedValue': ?correctedValue},
    ),
  );

  @override
  Future<List<SettlementSummary>> settlements(String date) async =>
      (await _list('/settlements', {
        'date': date,
      })).map(SettlementSummary.fromJson).toList();

  @override
  Future<SettlementDetail> settlement(String date, String driverId) async =>
      SettlementDetail.fromJson(
        await _obj('GET', '/settlements/$date/drivers/$driverId'),
      );

  @override
  Future<SettlementDetail> settle(
    String date,
    String driverId, {
    required String idempotencyKey,
  }) async => SettlementDetail.fromJson(
    await _obj(
      'POST',
      '/settlements/$date/drivers/$driverId/settle',
      idempotencyKey: idempotencyKey,
    ),
  );

  @override
  Future<MediaUrl> mediaUrl(String mediaId) async =>
      MediaUrl.fromJson(await _obj('GET', '/media/$mediaId/url'));
}
