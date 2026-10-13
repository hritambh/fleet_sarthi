import 'http_api.dart';
import 'json.dart';
import 'models.dart';
import 'owner_models.dart';

/// What a driver sees about themselves: their profile, their documents (which
/// the owner approves) and their trips over any period. Online-only, unlike
/// the synced trip list.
abstract class MeApi {
  /// The driver's own record in the active fleet (name, phone, cabs).
  Future<Driver> driver();

  /// Changes the driver's own profile (name, photoMediaId, dateOfBirth,
  /// email, address, emergency contact); null clears a field.
  Future<Driver> updateProfile(JsonMap body);

  /// Sends a code to [phone], the number the driver wants to move to.
  Future<void> requestPhoneOtp(String phone);

  /// Moves the account to [phone] with the code sent to it; returns it.
  Future<String> changePhone(String phone, String code);

  Future<List<FleetDocument>> documents();

  /// Adds a document; it waits for the owner's approval.
  Future<FleetDocument> submitDocument(JsonMap body);

  /// Uploads a renewed copy; it replaces [id] once approved.
  Future<FleetDocument> renewDocument(String id, JsonMap body);

  /// The driver's trips overlapping [from, to) (at most 62 days), any status.
  Future<List<Trip>> tripsBetween(DateTime from, DateTime to);
}

class HttpMeApi implements MeApi {
  HttpMeApi(this._http);
  final HttpTaxcyApi _http;

  Future<JsonMap> _obj(String method, String path, {Object? body}) async =>
      asJsonMap(await _http.send(method, path, body: body));

  @override
  Future<Driver> driver() async =>
      Driver.fromJson(await _obj('GET', '/me/driver'));

  @override
  Future<Driver> updateProfile(JsonMap body) async =>
      Driver.fromJson(await _obj('PATCH', '/me/driver', body: body));

  @override
  Future<void> requestPhoneOtp(String phone) =>
      _http.send('POST', '/me/phone/otp', body: {'phone': phone});

  @override
  Future<String> changePhone(String phone, String code) async => asJsonMap(
    await _http.send('POST', '/me/phone', body: {'phone': phone, 'code': code}),
  ).str('phone');

  @override
  Future<List<FleetDocument>> documents() async => jsonList(
    await _http.send('GET', '/me/documents'),
  ).map(FleetDocument.fromJson).toList();

  @override
  Future<FleetDocument> submitDocument(JsonMap body) async =>
      FleetDocument.fromJson(await _obj('POST', '/me/documents', body: body));

  @override
  Future<FleetDocument> renewDocument(String id, JsonMap body) async =>
      FleetDocument.fromJson(
        await _obj('POST', '/me/documents/$id/renew', body: body),
      );

  @override
  Future<List<Trip>> tripsBetween(DateTime from, DateTime to) async => jsonList(
    await _http.send(
      'GET',
      '/me/trips/range',
      query: {
        'from': from.toUtc().toIso8601String(),
        'to': to.toUtc().toIso8601String(),
      },
    ),
  ).map(Trip.fromJson).toList();
}
