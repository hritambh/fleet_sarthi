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
