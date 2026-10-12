// Typed mirrors of the sign-in contracts (libs/contracts/src/routes/identity.ts):
// the password-reset code and the signed-in account.
import 'json.dart';

/// A password-reset code was sent (`POST /auth/otp/request`).
class OtpTicket {
  const OtpTicket({
    required this.expiresInSeconds,
    required this.resendAfterSeconds,
  });

  factory OtpTicket.fromJson(JsonMap json) => OtpTicket(
    expiresInSeconds: json.integer('expiresInSeconds'),
    resendAfterSeconds: json.integer('resendAfterSeconds'),
  );

  final int expiresInSeconds;

  /// How long to wait before another code can be sent.
  final int resendAfterSeconds;
}

/// The signed-in user's account (`GET /me`).
class Account {
  const Account({
    required this.id,
    required this.phone,
    required this.name,
    required this.hasPassword,
  });

  factory Account.fromJson(JsonMap json) {
    final user = json.obj('user');
    return Account(
      id: user.str('id'),
      phone: user.str('phone'),
      name: user.strOrNull('name'),
      hasPassword: user.boolean('hasPassword'),
    );
  }

  final String id;
  final String phone;
  final String? name;
  final bool hasPassword;
}

/// Phone OTP as the server offers it (`GET /auth/methods`).
class PhoneOtpMethod {
  const PhoneOtpMethod({required this.provider, this.clientId});

  factory PhoneOtpMethod.fromJson(JsonMap json) => PhoneOtpMethod(
    provider: json.str('provider'),
    clientId: json.strOrNull('clientId'),
  );

  /// `phone_email`, or `stub` (development: any number, no real OTP).
  final String provider;

  /// phone.email's public client id.
  final String? clientId;
}

/// Which sign-in methods the server offers (`GET /auth/methods`).
class AuthMethods {
  const AuthMethods({this.phoneOtp, this.signupRequiresVerifiedPhone = false});

  factory AuthMethods.fromJson(JsonMap json) {
    final otp = json['phoneOtp'];
    return AuthMethods(
      phoneOtp: otp == null ? null : PhoneOtpMethod.fromJson(asJsonMap(otp)),
      signupRequiresVerifiedPhone: json['signupRequiresVerifiedPhone'] == true,
    );
  }

  /// Passwords and reset codes only (also what an unreachable server means).
  static const none = AuthMethods();

  final PhoneOtpMethod? phoneOtp;
  final bool signupRequiresVerifiedPhone;
}
