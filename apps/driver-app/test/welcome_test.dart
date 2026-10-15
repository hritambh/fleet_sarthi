import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/app/app.dart';

import 'support/harness.dart';

const _scroll = Key('welcome-scroll');

/// The app, signed out, showing the web's full landing page (or the
/// installed app's short welcome with [compact]).
Future<Harness> firstVisit(
  WidgetTester tester, {
  String language = 'en',
  Size size = const Size(420, 2000),
  bool compact = false,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
  final h = await Harness.create(language: language)
    ..compactWelcome = compact;
  addTearDown(h.dispose);
  await tester.pumpWidget(h.wrap(const TaxcyDriverApp()));
  await settle(tester);
  return h;
}

Future<void> tapVisible(WidgetTester tester, Key key) async {
  await tester.scrollUntilVisible(
    find.byKey(key),
    300,
    scrollable: find.descendant(
      of: find.byKey(_scroll),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.tap(find.byKey(key));
  await settle(tester);
}

void main() {
  testWidgets('signed out, the app opens on the welcome page', (tester) async {
    await firstVisit(tester);
    expect(find.text('Know what your cars'), findsOneWidget);
    expect(find.text('really did today.'), findsOneWidget);
    // The hero's Today card shows each cab's day, as on the dashboard.
    expect(find.text('Cabs today'), findsWidgets);
    expect(find.text('JH08KA8474'), findsWidgets);
    expect(find.byKey(const Key('password-field')), findsNothing);
  });

  testWidgets('get started opens sign up', (tester) async {
    await firstVisit(tester);
    await tapVisible(tester, const Key('welcome-get-started'));
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.byKey(const Key('new-password-field')), findsOneWidget);
  });

  testWidgets('the final call to action opens sign up too', (tester) async {
    await firstVisit(tester);
    await tapVisible(tester, const Key('welcome-final-cta'));
    expect(find.text('Create your account'), findsOneWidget);
  });

  testWidgets('sign in opens the login card, which can go back', (
    tester,
  ) async {
    await firstVisit(tester);
    await tapVisible(tester, const Key('welcome-sign-in'));
    expect(find.byKey(const Key('password-field')), findsOneWidget);
    await tester.tap(find.byKey(const Key('login-about')));
    await settle(tester);
    expect(find.text('Know what your cars'), findsOneWidget);
  });

  testWidgets('the FAQ opens an answer', (tester) async {
    await firstVisit(tester);
    const question = 'Do my drivers need internet all the time?';
    await tester.scrollUntilVisible(
      find.text(question),
      300,
      scrollable: find.descendant(
        of: find.byKey(_scroll),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.text(question));
    // The carousel keeps animating, so pump past the expansion instead of
    // waiting to settle.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(
      find.textContaining('saves everything on the phone'),
      findsOneWidget,
    );
  });

  testWidgets('the hero carousel moves on by itself and by tab', (
    tester,
  ) async {
    await firstVisit(tester);
    expect(find.text('Km driven'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Km driven'), findsNothing);
    expect(find.text('45,361'), findsWidgets);
    await tester.tap(find.byKey(const Key('welcome-slide-3')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Expiring soon'), findsWidgets);
  });

  testWidgets('scrolling walks through every use case', (tester) async {
    await firstVisit(tester);
    for (final useCase in [
      'fuel',
      'trips',
      'availability',
      'settlement',
      'documents',
      'offline',
    ]) {
      await tester.scrollUntilVisible(
        find.byKey(Key('welcome-usecase-$useCase')),
        300,
        scrollable: find.descendant(
          of: find.byKey(_scroll),
          matching: find.byType(Scrollable),
        ),
      );
    }
    expect(find.text('Built for highways and ghat roads'), findsOneWidget);
    expect(find.text('Ramesh hands over'), findsWidgets);
  });

  group('in the installed app', () {
    testWidgets('a short welcome, not the landing page', (tester) async {
      await firstVisit(tester, compact: true, size: const Size(390, 844));
      expect(find.byKey(const Key('welcome-app')), findsOneWidget);
      expect(find.text('Know what your cars'), findsOneWidget);
      expect(find.text('Fuel audit'), findsOneWidget);
      // None of the landing page's sections.
      expect(find.byKey(const Key('welcome-scroll')), findsNothing);
      expect(find.text('Questions owners ask'), findsNothing);
      expect(find.byKey(const Key('welcome-slide-0')), findsNothing);
      // The version in small print (local and test runs say "dev").
      expect(find.text('vdev'), findsOneWidget);
    });

    testWidgets('get started opens sign up; sign in the login card', (
      tester,
    ) async {
      await firstVisit(tester, compact: true, size: const Size(390, 844));
      await tester.tap(find.byKey(const Key('welcome-get-started')));
      await settle(tester);
      expect(find.text('Create your account'), findsOneWidget);
      await tester.tap(find.byKey(const Key('login-about')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('welcome-sign-in')));
      await settle(tester);
      expect(find.byKey(const Key('password-field')), findsOneWidget);
      expect(find.byKey(const Key('login-version')), findsOneWidget);
    });

    // A small phone and Hindi: no overflow (it scrolls if it must).
    for (final language in ['en', 'hi']) {
      testWidgets('fits a 360 × 640 phone ($language)', (tester) async {
        await firstVisit(
          tester,
          compact: true,
          language: language,
          size: const Size(360, 640),
        );
        expect(find.byKey(const Key('welcome-app')), findsOneWidget);
      });
    }
  });

  // Every section is built (the page is one column), so any overflow at these
  // sizes fails the test with the widget at fault.
  for (final language in ['en', 'hi']) {
    for (final (name, size) in [
      ('360 px phone', const Size(360, 1600)),
      ('tablet', const Size(800, 1200)),
      ('laptop', const Size(1366, 900)),
    ]) {
      testWidgets('lays out on a $name ($language)', (tester) async {
        await firstVisit(tester, language: language, size: size);
        expect(find.byKey(_scroll), findsOneWidget);
      });
    }
  }
}
