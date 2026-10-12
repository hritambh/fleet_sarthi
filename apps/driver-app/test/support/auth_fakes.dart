import 'package:flutter/widgets.dart';
import 'package:taxcy_driver/core/api/api.dart';
import 'package:taxcy_driver/core/api/auth_api.dart';
import 'package:taxcy_driver/core/api/auth_models.dart';
import 'package:taxcy_driver/core/api/json.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/login/phone_verification.dart';

import 'fakes.dart';

/// GET /me as the API returns it.
JsonMap accountJson({bool hasPassword = false}) => {
  'user': {
    'id': '0199c7a2-0000-7000-8000-0000000000f1',
    'phone': '+919000000011',
    'name': 'Ramesh Kumar',
    'hasPassword': hasPassword,
  },
  'activeOrgId': '0199c7a2-0000-7000-8000-000000000999',
  'roles': ['driver'],
  'memberships': <Object?>[],
};

/// Records every sign-in call. `failNext` scripts failures for a call name;
/// [roles] decides who the signed-in session belongs to.
class FakeAuthApi implements AuthApi {
  final calls = <ApiCall>[];
  final _failures = <String, List<Object>>{};

  List<String> roles = const ['driver'];
  int resendAfterSeconds = 30;
  JsonMap accountData = accountJson();

  void failNext(String call, Object error, {int times = 1}) =>
      (_failures[call] ??= []).addAll(List.filled(times, error));

  static ApiException error(String code, {int status = 400}) =>
      ApiException(status: status, code: code, message: code);

  List<String> get names => calls.map((c) => c.name).toList();

  void _record(String name, [JsonMap args = const {}]) {
    calls.add(ApiCall(name, args));
    final queue = _failures[name];
    if (queue != null && queue.isNotEmpty) throw queue.removeAt(0);
  }

  Session _session() => Session.fromJson(sessionJson(roles: roles));

  @override
  Future<OtpTicket> requestOtp(String phone) async {
    _record('requestOtp', {'phone': phone});
    return OtpTicket(
      expiresInSeconds: 300,
      resendAfterSeconds: resendAfterSeconds,
    );
  }

  @override
  Future<Session> signUp({
    required String phone,
    required String password,
    required DeviceInfo device,
    String? name,
    String? verificationToken,
  }) async {
    _record('signUp', {
      'phone': phone,
      'password': password,
      'name': name,
      'verificationToken': ?verificationToken,
      'platform': device.platform,
    });
    return _session();
  }

  /// What GET /auth/methods answers; passwords only by default.
  AuthMethods authMethods = AuthMethods.none;

  @override
  Future<AuthMethods> methods() async {
    _record('methods');
    return authMethods;
  }

  @override
  Future<Session> phoneOtpLogin({
    required String verificationToken,
    required DeviceInfo device,
  }) async {
    _record('phoneOtpLogin', {'verificationToken': verificationToken});
    return _session();
  }

  @override
  Future<Session> resetPasswordVerified({
    required String verificationToken,
    required String password,
    required DeviceInfo device,
  }) async {
    _record('resetPasswordVerified', {
      'verificationToken': verificationToken,
      'password': password,
    });
    return _session();
  }

  @override
  Future<Session> passwordLogin({
    required String phone,
    required String password,
    required DeviceInfo device,
  }) async {
    _record('passwordLogin', {'phone': phone, 'password': password});
    return _session();
  }

  @override
  Future<Session> resetPassword({
    required String phone,
    required String code,
    required String password,
    required DeviceInfo device,
  }) async {
    _record('resetPassword', {
      'phone': phone,
      'code': code,
      'password': password,
    });
    return _session();
  }

  @override
  Future<void> changePassword({
    required String newPassword,
    String? currentPassword,
  }) async => _record('changePassword', {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  });

  @override
  Future<Account> account() async {
    _record('account');
    return Account.fromJson(accountData);
  }

  @override
  Future<void> logout(String refreshToken) async => _record('logout');

  /// What GET /me lists; [switchOrg] and [createOrg] use it for the session
  /// they return.
  List<Membership> currentMemberships = const [];

  Session _sessionIn(String orgId) => Session.fromJson({
    ...sessionJson(roles: roles),
    'activeOrgId': orgId,
    'memberships': currentMemberships.map((m) => m.toJson()).toList(),
  });

  @override
  Future<List<Membership>> memberships() async {
    _record('memberships');
    return currentMemberships;
  }

  @override
  Future<Session> switchOrg(String orgId) async {
    _record('switchOrg', {'orgId': orgId});
    return _sessionIn(orgId);
  }

  @override
  Future<Session> createOrg({
    required String name,
    required String kind,
  }) async {
    _record('createOrg', {'name': name, 'kind': kind});
    const orgId = '0199c7a2-0000-7000-8000-000000000777';
    currentMemberships = [
      ...currentMemberships,
      Membership(
        orgId: orgId,
        orgName: name,
        roles: ['owner', if (kind == 'dco') 'driver'],
      ),
    ];
    return _sessionIn(orgId);
  }
}

/// Stands in for phone.email's OTP screen: answers [token] (null = the user
/// backed out) and records the number hint it was given.
class FakePhoneVerifier implements PhoneVerifier {
  String? token = 'stub:+919000000011';
  bool supported = true;
  final hints = <String>[];

  @override
  bool supports(PhoneOtpMethod otp) => supported;

  @override
  Future<String?> verify(
    BuildContext context,
    PhoneOtpMethod otp, {
    required String deviceId,
    String phoneHint = '',
  }) async {
    hints.add(phoneHint);
    return token;
  }
}
