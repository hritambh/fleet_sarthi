import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/app/app.dart';

import 'support/harness.dart';

const _scroll = Key('welcome-scroll');

/// The app signed out on a device that has never been past the welcome page.
Future<Harness> firstVisit(
  WidgetTester tester, {
  String language = 'en',
  Size size = const Size(420, 2000),
  bool seen = false,
}) async {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(tester.view.reset);
  final h = await Harness.create(
    language: language,
    preferences: {'welcome_seen_v1': seen},
  );
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
  testWidgets('a first visit opens on the welcome page', (tester) async {
    await firstVisit(tester);
    expect(find.text('Know what your cars'), findsOneWidget);
    expect(find.text('really did today.'), findsOneWidget);
    expect(find.byKey(const Key('password-field')), findsNothing);
  });

  testWidgets('get started opens sign up, and is remembered', (tester) async {
    final h = await firstVisit(tester);
    await tapVisible(tester, const Key('welcome-get-started'));
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.byKey(const Key('new-password-field')), findsOneWidget);
    expect(h.prefs.getBool('welcome_seen_v1'), isTrue);
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

  testWidgets('a returning visitor goes straight to the login card', (
    tester,
  ) async {
    await firstVisit(tester, seen: true);
    expect(find.byKey(const Key('password-field')), findsOneWidget);
    expect(find.text('What is Fleet Sarthi?'), findsOneWidget);
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
