import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/common/consent_screen.dart';
import '../core/api/models.dart';
import '../features/common/widgets.dart';
import '../features/login/auth_forms.dart';
import '../features/login/login_screen.dart';
import '../features/owner/owner_shell.dart';
import '../features/welcome/welcome_screen.dart';
import '../features/driver/driver_shell.dart';
import '../features/workspaces/get_started_screen.dart';
import '../l10n/app_localizations.dart';
import 'preferences.dart';
import 'providers.dart';
import 'sync_coordinator.dart';
import 'theme.dart';

class TaxcyDriverApp extends ConsumerWidget {
  const TaxcyDriverApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    theme: buildTheme(),
    // Null follows the phone's language (English when it isn't supported).
    locale: ref.watch(localeProvider),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const _Root(),
  );
}

/// Signed out → the welcome page on a first visit, else login. Signed in: owners and managers get owner mode, drivers
/// their trips (after the first-run location consent). An owner-driver (DCO)
/// switches between the two; the choice is remembered. Someone in no fleet yet
/// gets the get-started screen (drive for an owner, or set up a fleet).
class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    return auth.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => const _SignedOut(),
      data: (session) {
        if (session == null) return const _SignedOut();
        final mode = screensFor(session, ref.watch(appModeProvider));
        return switch (mode) {
          // A DCO's trips keep syncing and recording GPS in owner mode.
          AppMode.owner when session.isDriver => const SyncCoordinator(
            child: SyncNoticeListener(child: OwnerShell()),
          ),
          AppMode.owner => const OwnerShell(),
          AppMode.driver => const _DriverHome(),
          null => const GetStartedScreen(),
        };
      },
    );
  }
}

/// The welcome page until the visitor picks "Get started" (sign up) or
/// "Sign in"; then the login card, which can go back to the welcome page.
class _SignedOut extends ConsumerStatefulWidget {
  const _SignedOut();

  @override
  ConsumerState<_SignedOut> createState() => _SignedOutState();
}

class _SignedOutState extends ConsumerState<_SignedOut> {
  late bool _welcome = !ref.read(welcomeSeenProvider);
  LoginFlow _flow = LoginFlow.password;

  void _login(LoginFlow flow) {
    ref.read(welcomeSeenProvider.notifier).markSeen();
    setState(() {
      _welcome = false;
      _flow = flow;
    });
  }

  @override
  Widget build(BuildContext context) => _welcome
      ? WelcomeScreen(
          onGetStarted: () => _login(LoginFlow.signUp),
          onSignIn: () => _login(LoginFlow.password),
        )
      : LoginScreen(
          key: ValueKey(_flow),
          initialFlow: _flow,
          onAbout: () => setState(() => _welcome = true),
        );
}

/// Which screens a signed-in member gets in the active fleet: owner mode for
/// staff, the driver screens for drivers, and for someone with both (a DCO)
/// their last choice, starting in owner mode. Null when they have neither role
/// there (or no fleet yet).
AppMode? screensFor(Session session, AppMode? chosen) {
  if (session.isStaff && session.isDriver) return chosen ?? AppMode.owner;
  if (session.isStaff) return AppMode.owner;
  if (session.isDriver) return AppMode.driver;
  return null;
}

/// The offline-first driver screens: location consent on first run, then the
/// driver's trips with background sync.
class _DriverHome extends ConsumerStatefulWidget {
  const _DriverHome();

  @override
  ConsumerState<_DriverHome> createState() => _DriverHomeState();
}

class _DriverHomeState extends ConsumerState<_DriverHome> {
  bool? _consented;

  @override
  void initState() {
    super.initState();
    if (!ref.read(backgroundWorkProvider)) {
      _consented = true;
      return;
    }
    hasLocationConsent().then((value) {
      if (mounted) setState(() => _consented = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_consented == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_consented == false) {
      return LocationConsentScreen(
        onDone: () => setState(() => _consented = true),
      );
    }
    return const SyncCoordinator(
      child: SyncNoticeListener(child: DriverShell()),
    );
  }
}
