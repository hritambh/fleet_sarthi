import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/core/api/auth_models.dart';
import 'package:taxcy_driver/features/login/phone_email_result.dart';
import 'package:taxcy_driver/features/login/phone_verification.dart';

import 'auth_flows_test.dart' show signedOut, tapKey, trips, type;
import 'support/auth_fakes.dart';
import 'support/harness.dart';

const _phone = Key('phone-field');
const _submit = Key('login-submit');
const _otpOn = AuthMethods(
  phoneOtp: PhoneOtpMethod(provider: 'phone_email', clientId: 'client-1'),
);

/// Signed out, with the server offering phone OTP.
Future<Harness> withOtp(WidgetTester tester, {AuthMethods methods = _otpOn}) =>
    signedOut(tester, setUp: (h) => h.auth.authMethods = methods);

void main() {
  group('phone OTP switched off', () {
    testWidgets('only passwords and reset codes are offered', (tester) async {
      await signedOut(tester);
      expect(find.byKey(const Key('otp-login')), findsNothing);
      await tapKey(tester, const Key('go-sign-up'));
      expect(find.text('Create account'), findsOneWidget);
      await tapKey(tester, const Key('go-log-in'));
      await tapKey(tester, const Key('go-forgot'));
      expect(find.byKey(const Key('code-field')), findsNothing);
      expect(find.text('Send code'), findsOneWidget);
    });

    testWidgets('nor where this platform has no phone.email sign-in', (
      tester,
    ) async {
      await signedOut(
        tester,
        setUp: (h) {
          h.auth.authMethods = _otpOn;
          h.phoneVerifier.supported = false;
        },
      );
      expect(find.byKey(const Key('otp-login')), findsNothing);
    });
  });

  group('phone OTP switched on', () {
    testWidgets('logs in with an OTP instead of a password', (tester) async {
      final h = await withOtp(tester);
      await type(tester, _phone, '9000000011');
      await tapKey(tester, const Key('otp-login'));
      expect(h.phoneVerifier.hints, ['9000000011']);
      expect(h.auth.calls.last.name, 'phoneOtpLogin');
      expect(h.auth.calls.last.args, {
        'verificationToken': 'stub:+919000000011',
      });
      expect(trips, findsOneWidget);
    });

    testWidgets('backing out of the OTP screen changes nothing', (
      tester,
    ) async {
      final h = await withOtp(tester);
      h.phoneVerifier.token = null;
      await tapKey(tester, const Key('otp-login'));
      expect(h.auth.names, isNot(contains('phoneOtpLogin')));
      expect(find.byKey(_phone), findsOneWidget);
    });

    testWidgets('a number with no account is offered sign-up', (tester) async {
      final h = await withOtp(tester);
      h.auth.failNext(
        'phoneOtpLogin',
        FakeAuthApi.error('NOT_FOUND', status: 404),
      );
      await tapKey(tester, const Key('otp-login'));
      expect(
        find.text('No account with this number yet. Sign up instead.'),
        findsOneWidget,
      );
      await tapKey(tester, const Key('no-account-sign-up'));
      expect(find.text('Verify number & create account'), findsOneWidget);
    });

    testWidgets('sign-up verifies the number first and sends the proof', (
      tester,
    ) async {
      final h = await withOtp(tester);
      await tapKey(tester, const Key('go-sign-up'));
      await type(tester, _phone, '9000000099');
      await type(tester, const Key('new-password-field'), 'secret-pass');
      await type(tester, const Key('confirm-password-field'), 'secret-pass');
      h.phoneVerifier.token = 'stub:+919000000099';
      await tapKey(tester, _submit);
      expect(h.phoneVerifier.hints, ['9000000099']);
      expect(h.auth.calls.last.name, 'signUp');
      expect(h.auth.calls.last.args['verificationToken'], 'stub:+919000000099');
    });

    testWidgets('a different verified number is explained', (tester) async {
      final h = await withOtp(tester);
      h.auth.failNext(
        'signUp',
        FakeAuthApi.error('PHONE_MISMATCH', status: 422),
      );
      await tapKey(tester, const Key('go-sign-up'));
      await type(tester, _phone, '9000000099');
      await type(tester, const Key('new-password-field'), 'secret-pass');
      await type(tester, const Key('confirm-password-field'), 'secret-pass');
      await tapKey(tester, _submit);
      expect(
        find.text("The number you verified isn't the one you entered."),
        findsOneWidget,
      );
    });

    testWidgets('forgot password: verify by OTP, then a new password', (
      tester,
    ) async {
      final h = await withOtp(tester);
      await tapKey(tester, const Key('go-forgot'));
      expect(find.text('Send code'), findsNothing);
      expect(find.byKey(const Key('new-password-field')), findsNothing);

      await tapKey(tester, _submit); // Verify with OTP
      expect(find.byKey(const Key('reset-verified')), findsOneWidget);
      await type(tester, const Key('new-password-field'), 'brand-new-pass');
      await type(tester, const Key('confirm-password-field'), 'brand-new-pass');
      await tapKey(tester, _submit);
      expect(h.auth.calls.last.name, 'resetPasswordVerified');
      expect(h.auth.calls.last.args, {
        'verificationToken': 'stub:+919000000011',
        'password': 'brand-new-pass',
      });
      expect(trips, findsOneWidget);
    });

    testWidgets('a failed reset asks to verify again', (tester) async {
      final h = await withOtp(tester);
      h.auth.failNext(
        'resetPasswordVerified',
        FakeAuthApi.error('PHONE_NOT_VERIFIED', status: 401),
      );
      await tapKey(tester, const Key('go-forgot'));
      await tapKey(tester, _submit);
      await type(tester, const Key('new-password-field'), 'brand-new-pass');
      await type(tester, const Key('confirm-password-field'), 'brand-new-pass');
      await tapKey(tester, _submit);
      expect(
        find.text("Couldn't verify your number. Try again."),
        findsOneWidget,
      );
      expect(find.text('Verify with OTP'), findsOneWidget);
    });
  });

  test("reads the token from phone.email's web result", () {
    expect(
      accessTokenFromUserJsonUrl('https://user.phone.email/user_abc-123.json'),
      'abc-123',
    );
    expect(
      accessTokenFromUserJsonUrl('https://evil.example/user_x.json'),
      isNull,
    );
    expect(accessTokenFromUserJsonUrl(null), isNull);
  });

  test('the phone.email sign-in page always asks for a fresh OTP', () {
    expect(
      PhoneEmailScreen.signInUrl('client-1', 'device-9').toString(),
      'https://auth.phone.email/log-in?client_id=client-1&device=device-9'
      '&auth_type=5&mode=othernum',
    );
    // The number typed in our form is pre-filled; anything else is left out.
    expect(
      PhoneEmailScreen.signInUrl(
        'client-1',
        'device-9',
        phoneHint: '9876543210',
      ).queryParameters,
      containsPair('user_phone_no', '9876543210'),
    );
    expect(freshOtpParams('12345'), {'mode': 'othernum'});
  });
}
