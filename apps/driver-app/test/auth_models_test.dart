import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/auth_models.dart';
import 'package:taxcy_driver/core/api/json.dart';

import 'support/auth_fakes.dart';

void main() {
  test('OtpTicket parses the resend wait', () {
    final ticket = OtpTicket.fromJson({
      'expiresInSeconds': 300,
      'resendAfterSeconds': 30,
    });
    expect(ticket.expiresInSeconds, 300);
    expect(ticket.resendAfterSeconds, 30);
  });

  test('Account parses GET /me', () {
    final account = Account.fromJson(accountJson(hasPassword: true));
    expect(account.phone, '+919000000011');
    expect(account.name, 'Ramesh Kumar');
    expect(account.hasPassword, isTrue);

    expect(Account.fromJson(accountJson()).hasPassword, isFalse);
  });

  test('a broken account payload fails loudly', () {
    expect(
      () => Account.fromJson({
        'user': <String, Object?>{'id': 'x'},
      }),
      throwsA(isA<JsonShapeError>()),
    );
  });
}
