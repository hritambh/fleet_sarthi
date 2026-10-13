import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/app/app.dart';
import 'package:taxcy_driver/core/api/json.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/account/account_security_screen.dart';

import 'support/auth_fakes.dart';
import 'support/fakes.dart';
import 'support/harness.dart';

const _phone = Key('phone-field');
const _code = Key('code-field');
const _password = Key('password-field');
const _newPassword = Key('new-password-field');
const _confirm = Key('confirm-password-field');
const _submit = Key('login-submit');

/// The app, signed out, on a tall phone (so the whole login card fits).
Future<Harness> signedOut(
  WidgetTester tester, {
  String language = 'en',
  double width = 420,
  void Function(Harness h)? setUp,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = Size(width, 1800);
  addTearDown(tester.view.reset);
  final h = await Harness.create(language: language);
  addTearDown(h.dispose);
  setUp?.call(h);
  await tester.pumpWidget(h.wrap(const TaxcyDriverApp()));
  await settle(tester);
  return h;
}

Future<void> tapKey(WidgetTester tester, Key key) async {
  await tester.tap(find.byKey(key));
  await settle(tester);
}

Future<void> type(WidgetTester tester, Key key, String text) =>
    tester.enterText(find.byKey(key), text);

Finder get trips => find.text('My trips');

void main() {
  group('password login', () {
    testWidgets('is the default, and signs a driver in', (tester) async {
      final h = await signedOut(tester);
      expect(find.byKey(_password), findsOneWidget);
      expect(find.byKey(_code), findsNothing);

      await type(tester, _phone, '9000000011');
      await tapKey(tester, _submit);
      expect(find.text('Enter your password'), findsOneWidget);
      expect(h.auth.names, isNot(contains('passwordLogin')));

      await type(tester, _password, 'correct horse');
      await tapKey(tester, _submit);
      expect(h.auth.calls.last.name, 'passwordLogin');
      expect(h.auth.calls.last.args, {
        'phone': '+919000000011',
        'password': 'correct horse',
      });
      expect(trips, findsOneWidget);
      expect((await h.sessions.load())?.isDriver, isTrue);
    });

    testWidgets('a wrong password says so and stays on the login screen', (
      tester,
    ) async {
      final h = await signedOut(tester);
      h.auth.failNext(
        'passwordLogin',
        FakeAuthApi.error('INVALID_CREDENTIALS', status: 401),
      );
      await type(tester, _phone, '9000000011');
      await type(tester, _password, 'wrong password');
      await tapKey(tester, _submit);
      expect(find.text('Wrong mobile number or password.'), findsOneWidget);
      expect(trips, findsNothing);
      expect(await h.sessions.load(), isNull);
    });

    testWidgets('the password field hides the password until asked', (
      tester,
    ) async {
      await signedOut(tester);
      TextField field() => tester.widget<TextField>(
        find.descendant(
          of: find.byKey(_password),
          matching: find.byType(TextField),
        ),
      );
      expect(field().obscureText, isTrue);
      expect(field().autofillHints, [AutofillHints.password]);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(field().obscureText, isFalse);
    });

    testWidgets('a pasted +91 number keeps the 10 digits', (tester) async {
      await signedOut(tester);
      await type(tester, _phone, '+91 90000 00011');
      await tester.pump();
      expect(find.text('9000000011'), findsOneWidget);
    });
  });

  group('sign up', () {
    /// Opens sign-up and fills every field (no SMS code any more).
    Future<void> fill(
      WidgetTester tester, {
      String password = 'long enough',
      String again = 'long enough',
      String? name,
    }) async {
      await tapKey(tester, const Key('go-sign-up'));
      expect(find.byKey(_code), findsNothing);
      await type(tester, _phone, '9000000011');
      if (name != null) await type(tester, const Key('name-field'), name);
      await type(tester, _newPassword, password);
      await type(tester, _confirm, again);
    }

    testWidgets('number, name and password → an owner lands in owner mode', (
      tester,
    ) async {
      final h = await signedOut(tester);
      h.auth.roles = const ['owner'];
      await fill(tester, name: 'Asha Patil', password: 'short', again: 'short');
      expect(find.text('Create your account'), findsOneWidget);
      await tapKey(tester, _submit);
      expect(find.text('Use at least 8 characters.'), findsOneWidget);

      await type(tester, _newPassword, 'long enough 1');
      await type(tester, _confirm, 'long enough 2');
      await tapKey(tester, _submit);
      expect(find.text("The two passwords don't match."), findsOneWidget);
      expect(h.auth.names, isNot(contains('signUp')));

      await type(tester, _confirm, 'long enough 1');
      await tapKey(tester, _submit);
      expect(h.auth.names, isNot(contains('requestOtp')));
      expect(h.auth.calls.last.args, {
        'phone': '+919000000011',
        'password': 'long enough 1',
        'name': 'Asha Patil',
        'platform': 'android',
      });
      expect(find.byKey(const Key('owner-nav')), findsOneWidget);
    });

    testWidgets('a wrong number is caught before calling the server', (
      tester,
    ) async {
      final h = await signedOut(tester);
      await fill(tester);
      await type(tester, _phone, '12345');
      await tapKey(tester, _submit);
      expect(find.text('Enter your 10-digit mobile number'), findsOneWidget);
      expect(h.auth.names, isNot(contains('signUp')));
    });

    testWidgets('a driver is routed to their trips; no name is fine', (
      tester,
    ) async {
      final h = await signedOut(tester);
      await fill(tester);
      await tapKey(tester, _submit);
      expect(h.auth.calls.last.args['name'], isNull);
      expect(trips, findsOneWidget);
    });

    testWidgets('no role in any fleet yet: offered driving or a fleet', (
      tester,
    ) async {
      final h = await signedOut(tester);
      h.auth.roles = const [];
      await fill(tester);
      await tapKey(tester, _submit);
      expect(find.text('Welcome to Fleet Sarthi'), findsOneWidget);
      expect(find.byKey(const Key('check-again')), findsOneWidget);
      expect(find.byKey(const Key('set-up-fleet')), findsOneWidget);
    });

    testWidgets('an existing account is offered log in or reset', (
      tester,
    ) async {
      final h = await signedOut(tester);
      h.auth.failNext(
        'signUp',
        FakeAuthApi.error('ACCOUNT_EXISTS', status: 409),
      );
      await fill(tester);
      await tapKey(tester, _submit);
      expect(
        find.text(
          'This number already has an account. Log in, or reset your password.',
        ),
        findsOneWidget,
      );

      await tapKey(tester, const Key('account-exists-reset'));
      expect(find.text('Reset your password'), findsOneWidget);
      // The number carries over.
      expect(find.text('9000000011'), findsOneWidget);
      await tapKey(tester, const Key('go-log-in'));
      expect(find.byKey(_password), findsOneWidget);
      expect(find.text('9000000011'), findsOneWidget);
    });
  });

  testWidgets('forgot password: code → new password → signed in', (
    tester,
  ) async {
    final h = await signedOut(tester);
    await type(tester, _phone, '9000000011');
    await tapKey(tester, const Key('go-forgot'));
    expect(find.text('Reset your password'), findsOneWidget);
    // Locally and in the demo, the code is in the API log.
    expect(find.byKey(const Key('reset-code-hint')), findsOneWidget);
    expect(find.textContaining("API server's log"), findsOneWidget);

    await tapKey(tester, _submit);
    expect(h.auth.calls.last.name, 'requestOtp');
    expect(h.auth.calls.last.args['phone'], '+919000000011');
    expect(find.text('Resend code in 30 s'), findsOneWidget);
    await tester.pump(const Duration(seconds: 31));
    expect(find.text('Resend code'), findsOneWidget);
    h.auth.failNext('resetPassword', FakeAuthApi.error('OTP_INVALID'));
    await type(tester, _code, '111111');
    await type(tester, _newPassword, 'brand new pass');
    await type(tester, _confirm, 'brand new pass');
    await tapKey(tester, _submit);
    expect(find.byKey(const Key('login-error')), findsOneWidget);
    expect(trips, findsNothing);

    await type(tester, _code, '482913');
    await tapKey(tester, _submit);
    expect(h.auth.calls.last.args, {
      'phone': '+919000000011',
      'code': '482913',
      'password': 'brand new pass',
    });
    expect(trips, findsOneWidget);
  });

  group('account security', () {
    Future<Harness> signedIn(
      WidgetTester tester, {
      List<String> roles = const ['driver'],
      JsonMap? account,
    }) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(420, 1800);
      addTearDown(tester.view.reset);
      final h = await Harness.create(
        session: Session.fromJson(sessionJson(roles: roles)),
      );
      addTearDown(h.dispose);
      if (account != null) h.auth.accountData = account;
      await tester.pumpWidget(h.wrap(const TaxcyDriverApp()));
      await settle(tester);
      return h;
    }

    testWidgets('from the driver menu: set a first password', (tester) async {
      final h = await signedIn(tester);
      await tapKey(tester, const Key('driver-menu'));
      await tapKey(tester, const Key('driver-account-security'));
      expect(find.byType(AccountSecurityScreen), findsOneWidget);
      expect(find.text('Not set yet'), findsOneWidget);
      expect(find.byKey(const Key('current-password-field')), findsNothing);

      await type(tester, _newPassword, 'my new password');
      await type(tester, _confirm, 'my new password');
      h.auth.accountData = accountJson(hasPassword: true);
      await tapKey(tester, const Key('save-password'));
      expect(h.auth.calls.lastWhere((c) => c.name == 'changePassword').args, {
        'currentPassword': null,
        'newPassword': 'my new password',
      });
      expect(find.text('Password saved'), findsWidgets);
      // Reloaded: now it asks for the current password.
      expect(find.text('Set'), findsOneWidget);
      expect(find.byKey(const Key('current-password-field')), findsOneWidget);
    });

    testWidgets('change it: the current password must be right', (
      tester,
    ) async {
      final h = await signedIn(
        tester,
        roles: const ['owner'],
        account: accountJson(hasPassword: true),
      );
      await tester.tap(find.text('More'));
      await settle(tester);
      await tapKey(tester, const Key('more-account-security'));
      expect(find.text('+91 90000 00011'), findsOneWidget);
      expect(find.text('Change password'), findsOneWidget);

      await type(tester, _newPassword, 'my new password');
      await type(tester, _confirm, 'my new password');
      await tapKey(tester, const Key('save-password'));
      expect(find.text('Enter your password'), findsOneWidget);

      h.auth.failNext(
        'changePassword',
        FakeAuthApi.error('INVALID_CREDENTIALS', status: 401),
      );
      await type(tester, const Key('current-password-field'), 'not it');
      await tapKey(tester, const Key('save-password'));
      expect(find.text('Your current password is wrong.'), findsOneWidget);

      await type(tester, const Key('current-password-field'), 'old password');
      await tapKey(tester, const Key('save-password'));
      expect(h.auth.calls.lastWhere((c) => c.name == 'changePassword').args, {
        'currentPassword': 'old password',
        'newPassword': 'my new password',
      });
      expect(find.text('Password saved'), findsWidgets);
    });
  });

  testWidgets('signing out ends the session and shows the login screen', (
    tester,
  ) async {
    final h = await Harness.create(session: Session.fromJson(sessionJson()));
    addTearDown(h.dispose);
    await tester.pumpWidget(h.wrap(const TaxcyDriverApp()));
    await settle(tester);
    await tapKey(tester, const Key('driver-menu'));
    await tester.tap(find.text('Sign out'));
    await settle(tester);
    expect(h.auth.names, contains('logout'));
    expect(await h.sessions.load(), isNull);
    expect(find.byKey(_password), findsOneWidget);
  });

  group('on a 360 px phone', () {
    // Any overflow fails these tests.
    testWidgets('the login screen in English', (tester) async {
      await signedOut(tester, width: 360);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('New to Fleet Sarthi? Sign up'), findsOneWidget);
    });

    testWidgets('the login screen in Hindi', (tester) async {
      await signedOut(tester, language: 'hi', width: 360);
      expect(find.text('पासवर्ड'), findsOneWidget);
      expect(find.text('लॉग इन करें'), findsOneWidget);
      expect(find.text('पासवर्ड भूल गए?'), findsOneWidget);
      expect(find.text('फ़्लीट सारथी पर नए हैं? साइन अप करें'), findsOneWidget);
    });

    testWidgets('sign up in English with an error showing', (tester) async {
      await signedOut(tester, width: 360);
      await tapKey(tester, const Key('go-sign-up'));
      await type(tester, _phone, '9000000011');
      await type(tester, _newPassword, 'long enough');
      await type(tester, _confirm, 'different one');
      await tapKey(tester, _submit);
      expect(find.text("The two passwords don't match."), findsOneWidget);
    });

    testWidgets('sign up in Hindi with every field showing', (tester) async {
      await signedOut(tester, language: 'hi', width: 360);
      await tapKey(tester, const Key('go-sign-up'));
      expect(find.text('अपना अकाउंट बनाएँ'), findsOneWidget);
      expect(find.text('आपका नाम (ज़रूरी नहीं)'), findsOneWidget);
      await type(tester, _phone, '9000000011');
      await type(tester, _newPassword, 'long enough');
      await type(tester, _confirm, 'different one');
      await tapKey(tester, _submit);
      expect(find.text('दोनों पासवर्ड एक जैसे नहीं हैं।'), findsOneWidget);
    });

    testWidgets('forgot password in Hindi with the code step', (tester) async {
      await signedOut(tester, language: 'hi', width: 360);
      await type(tester, _phone, '9000000011');
      await tapKey(tester, const Key('go-forgot'));
      await tapKey(tester, _submit);
      expect(find.byKey(_code), findsOneWidget);
      expect(find.text('30 सेकंड बाद कोड फिर से भेजें'), findsOneWidget);
      expect(find.byKey(const Key('reset-code-hint')), findsOneWidget);
    });
  });
}
