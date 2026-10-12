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
  /// a password. [verificationToken] proves the number by OTP (required when
  /// the server's [AuthMethods.signupRequiresVerifiedPhone]).
  Future<Session> signUp({
    required String phone,
    required String password,
    required DeviceInfo device,
    String? name,
    String? verificationToken,
  });

  /// Which sign-in methods the server offers.
  Future<AuthMethods> methods();

  /// Whether [phone] has an account (checked before sending an OTP to log in).
  Future<bool> phoneOtpCheck(String phone);

  /// Signs in the owner of the number an OTP verified; NOT_FOUND when it has
  /// no account, PHONE_MISMATCH when it isn't [phone] (the number entered).
  Future<Session> phoneOtpLogin({
    required String verificationToken,
    required DeviceInfo device,
    String? phone,
  });

  /// A new password for the number an OTP verified (instead of a reset code).
  Future<Session> resetPasswordVerified({
    required String verificationToken,
    required String password,
    required DeviceInfo device,
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

  /// The fleets the user belongs to now, including any that added them since
  /// they signed in.
  Future<List<Membership>> memberships();

  /// A new session in [orgId], one of the user's fleets.
  Future<Session> switchOrg(String orgId);

  /// Creates a fleet owned by the user ([kind] `fleet`, or `dco` when they
  /// also drive) and returns a session in it.
  Future<Session> createOrg({required String name, required String kind});
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
    String? verificationToken,
  }) => _session('/auth/signup', {
    'phone': phone,
    'password': password,
    'name': ?name,
    'verificationToken': ?verificationToken,
    ..._device(device),
  });

  @override
  Future<AuthMethods> methods() async =>
      AuthMethods.fromJson(await _public('GET', '/auth/methods'));

  @override
  Future<bool> phoneOtpCheck(String phone) async =>
      (await _public('POST', '/auth/phone-otp/check', {
        'phone': phone,
      }))['exists'] ==
      true;

  @override
  Future<Session> phoneOtpLogin({
    required String verificationToken,
    required DeviceInfo device,
    String? phone,
  }) => _session('/auth/phone-otp/login', {
    'verificationToken': verificationToken,
    'phone': ?phone,
    ..._device(device),
  });

  @override
  Future<Session> resetPasswordVerified({
    required String verificationToken,
    required String password,
    required DeviceInfo device,
  }) => _session('/auth/password/reset-verified', {
    'verificationToken': verificationToken,
    'password': password,
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
  Future<List<Membership>> memberships() async => asJsonMap(
    await _api.send('GET', '/me'),
  ).objects('memberships').map(Membership.fromJson).toList();

  @override
  Future<Session> switchOrg(String orgId) async => Session.fromJson(
    asJsonMap(
      await _api.send(
        'POST',
        '/auth/switch-org',
        body: {'orgId': orgId},
        withRefreshToken: true,
      ),
    ),
  );

  @override
  Future<Session> createOrg({
    required String name,
    required String kind,
  }) async => Session.fromJson(
    asJsonMap(
      await _api.send(
        'POST',
        '/orgs',
        body: {'name': name, 'kind': kind},
        withRefreshToken: true,
      ),
    ),
  );

  @override
  Future<void> logout(String refreshToken) => _api.send(
    'POST',
    '/auth/logout',
    body: {'refreshToken': refreshToken},
    auth: false,
  );
}
