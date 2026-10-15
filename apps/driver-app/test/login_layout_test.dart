import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/features/login/login_illustration.dart';
import 'package:taxcy_driver/features/login/login_screen.dart';

import 'support/harness.dart';

Future<Harness> open(WidgetTester tester, Size size) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
  final h = await Harness.create(language: 'en');
  addTearDown(h.dispose);
  await tester.pumpWidget(h.screen(const LoginScreen()));
  await settle(tester);
  return h;
}

void main() {
  testWidgets('on a wide screen the form sits beside an illustration and a '
      'line about the company', (tester) async {
    await open(tester, const Size(1440, 900));
    expect(find.byKey(const Key('login-split')), findsOneWidget);
    expect(find.byType(LoginIllustration), findsOneWidget);
    expect(find.byKey(const Key('password-field')), findsOneWidget);
    final company = tester.widget<Text>(find.byKey(const Key('login-company')));
    expect(company.data, contains('© ${DateTime.now().year}'));
    expect(company.data, contains('cab operations'));
  });

  testWidgets('on a phone it is the single card, with no illustration', (
    tester,
  ) async {
    await open(tester, const Size(420, 900));
    expect(find.byKey(const Key('login-split')), findsNothing);
    expect(find.byType(LoginIllustration), findsNothing);
    expect(find.byKey(const Key('password-field')), findsOneWidget);
  });
}
