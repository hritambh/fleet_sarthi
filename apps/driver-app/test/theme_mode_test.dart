import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taxcy_driver/app/app.dart';
import 'package:taxcy_driver/app/preferences.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/features/driver/driver_profile_screen.dart';
import 'package:taxcy_driver/features/owner/settings_screen.dart';
import 'package:taxcy_driver/features/welcome/welcome_screen.dart';

import 'support/fakes.dart';
import 'support/harness.dart';

/// The brightness the app's screens are drawn in.
Brightness shown(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

void main() {
  Future<Harness> signedIn(
    WidgetTester tester, {
    Map<String, Object> preferences = const {},
  }) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(420, 1600);
    addTearDown(tester.view.reset);
    final h = await Harness.create(
      session: Session.fromJson(sessionJson(roles: ['owner'])),
      preferences: preferences,
    );
    addTearDown(h.dispose);
    return h;
  }

  testWidgets('the app follows the phone’s dark mode by default', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final h = await signedIn(tester);
    await tester.pumpWidget(h.wrap(const TaxcyDriverApp()));
    await settle(tester);
    expect(shown(tester), Brightness.dark);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    await settle(tester);
    expect(shown(tester), Brightness.light);
  });

  testWidgets('a saved choice wins over the phone’s setting', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final h = await signedIn(tester, preferences: {'theme_mode_v1': 'light'});
    await tester.pumpWidget(h.wrap(const TaxcyDriverApp()));
    await settle(tester);
    expect(shown(tester), Brightness.light);
  });

  testWidgets('Settings → Appearance switches the theme and remembers it', (
    tester,
  ) async {
    final h = await signedIn(tester);
    await tester.pumpWidget(h.screen(const SettingsScreen()));
    await settle(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsScreen)),
    );
    expect(find.text("Phone's setting"), findsOneWidget);

    Future<void> pick(String mode) async {
      await tester.tap(find.byKey(const Key('settings-appearance')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('theme-$mode')));
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    }

    await pick('dark');
    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(h.prefs.getString('theme_mode_v1'), 'dark');
    expect(find.text('Dark'), findsOneWidget);

    await pick('light');
    expect(h.prefs.getString('theme_mode_v1'), 'light');

    // Back to the phone's setting: nothing saved.
    await pick('system');
    expect(container.read(themeModeProvider), ThemeMode.system);
    expect(h.prefs.getString('theme_mode_v1'), isNull);
  });

  testWidgets('the sun/moon beside the alerts bell switches the theme', (
    tester,
  ) async {
    final h = await signedIn(tester);
    await tester.pumpWidget(h.wrap(const TaxcyDriverApp()));
    await settle(tester);
    expect(shown(tester), Brightness.light);

    // Right beside the bell, in the same app bar row.
    final toggle = find.byKey(const Key('theme-toggle')).first;
    final bell = find.byKey(const Key('alerts-bell')).first;
    expect(tester.getCenter(toggle).dy, tester.getCenter(bell).dy);
    expect(
      (tester.getCenter(bell).dx - tester.getCenter(toggle).dx).abs(),
      lessThan(60),
    );
    expect(find.byTooltip('Switch to dark mode'), findsWidgets);

    await tester.tap(toggle);
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    expect(shown(tester), Brightness.dark);
    expect(h.prefs.getString('theme_mode_v1'), 'dark');
    expect(find.byTooltip('Switch to light mode'), findsWidgets);

    await tester.tap(find.byKey(const Key('theme-toggle')).first);
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    expect(shown(tester), Brightness.light);
    expect(h.prefs.getString('theme_mode_v1'), 'light');
  });

  testWidgets('a driver finds Appearance on their profile', (tester) async {
    final h = await signedIn(tester);
    await tester.pumpWidget(h.screen(const DriverProfileScreen()));
    await settle(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('profile-appearance')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('profile-appearance')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('theme-dark')));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    expect(h.prefs.getString('theme_mode_v1'), 'dark');
  });

  testWidgets('signed out, the landing page stays light in dark mode', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    final h = await Harness.create();
    addTearDown(h.dispose);
    await tester.pumpWidget(h.wrap(const TaxcyDriverApp()));
    await settle(tester);
    expect(
      Theme.of(tester.element(find.byType(WelcomeScreen))).brightness,
      Brightness.light,
    );
  });
}
