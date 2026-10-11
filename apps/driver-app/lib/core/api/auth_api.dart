import 'auth_models.dart';
import 'http_api.dart';
import 'json.dart';
import 'models.dart';

/// The fields every sign-in sends so the server knows which device holds the
/// session.
typedef DeviceInfo = ({String deviceId, String platform});

/// Signing in (mobile number + password), signing up, resetting a forgotten
/// password and changing it. The login screens and the account screen depend on
/// this interface, so tests run against a fake.
abstract class AuthApi {
  /// Sends a password-reset code to [phone]. Locally and in demo mode the API
  /// prints the code in its log instead of sending an SMS.
  Future<OtpTicket> requestOtp(String phone);

  /// Phone + password sign-up. An invited number without a password gets this
  /// password and joins its fleet; ACCOUNT_EXISTS when the number already has
  /// a password.
  Future<Session> signUp({
    required String phone,
    required String password,
    required DeviceInfo device,
    String? name,
  });

  /// INVALID_CREDENTIALS for a wrong number or password alike.
  Future<Session> passwordLogin({
    required String phone,
    required String password,
    required DeviceInfo device,
  });

  /// A new password with a reset code; signs out every other session.
  Future<Session> resetPassword({
    required String phone,
    required String code,
    required String password,
    required DeviceInfo device,
  });

  /// Sets a password, or changes it ([currentPassword] needed if one is set).
  Future<void> changePassword({
    required String newPassword,
    String? currentPassword,
  });

  /// The signed-in user's account (and whether a password is set).
  Future<Account> account();

  Future<void> logout(String refreshToken);
}

/// [AuthApi] over the shared HTTP client (same base URL and token refresh).
class HttpAuthApi implements AuthApi {
  HttpAuthApi(this._api);
  final HttpTaxcyApi _api;

  JsonMap _device(DeviceInfo d) => {
    'deviceId': d.deviceId,
    'platform': d.platform,
  };

  Future<JsonMap> _public(String method, String path, [JsonMap? body]) async =>
      asJsonMap(await _api.send(method, path, body: body, auth: false));

  Future<Session> _session(String path, JsonMap body) async =>
      Session.fromJson(await _public('POST', path, body));

  @override
  Future<OtpTicket> requestOtp(String phone) async => OtpTicket.fromJson(
    await _public('POST', '/auth/otp/request', {'phone': phone}),
  );

  @override
  Future<Session> signUp({
    required String phone,
    required String password,
    required DeviceInfo device,
    String? name,
  }) => _session('/auth/signup', {
    'phone': phone,
    'password': password,
    'name': ?name,
    ..._device(device),
  });

  @override
  Future<Session> passwordLogin({
    required String phone,
    required String password,
    required DeviceInfo device,
  }) => _session('/auth/password/login', {
    'phone': phone,
    'password': password,
    ..._device(device),
  });

  @override
  Future<Session> resetPassword({
    required String phone,
    required String code,
    required String password,
    required DeviceInfo device,
  }) => _session('/auth/password/reset', {
    'phone': phone,
    'code': code,
    'password': password,
    ..._device(device),
  });

  @override
  Future<void> changePassword({
    required String newPassword,
    String? currentPassword,
  }) => _api.send(
    'POST',
    '/me/password',
    body: {'currentPassword': ?currentPassword, 'newPassword': newPassword},
  );

  @override
  Future<Account> account() async =>
      Account.fromJson(asJsonMap(await _api.send('GET', '/me')));

  @override
  Future<void> logout(String refreshToken) => _api.send(
    'POST',
    '/auth/logout',
    body: {'refreshToken': refreshToken},
    auth: false,
  );
}
