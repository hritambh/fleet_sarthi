import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../common/format.dart';
import '../common/language_picker.dart';
import 'auth_forms.dart';

/// Signing in: mobile number + password, plus sign-up and forgot password.
/// Every step lives in the same card, so a successful sign-in just replaces
/// this screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Shared by every step, so the number typed once carries over.
  final _phone = TextEditingController();
  LoginFlow _flow = LoginFlow.password;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _open(LoginFlow flow) => setState(() => _flow = flow);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [TaxcyColors.blue700, TaxcyColors.blue950],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_taxi,
                          color: TaxcyColors.blue700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Shrinks to fit next to the language button on narrow phones.
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            context.l10n.appTitle,
                            maxLines: 1,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const LanguageButton(color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _form(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _form() => switch (_flow) {
    LoginFlow.password => PasswordLoginForm(
      key: const ValueKey(LoginFlow.password),
      phone: _phone,
      onOpen: _open,
    ),
    LoginFlow.signUp => SignUpForm(
      key: const ValueKey(LoginFlow.signUp),
      phone: _phone,
      onOpen: _open,
    ),
    LoginFlow.reset => ResetPasswordForm(
      key: const ValueKey(LoginFlow.reset),
      phone: _phone,
      onOpen: _open,
    ),
  };
}

/// Signed in, but this number has no driver, owner or manager role in the
/// active organization.
class NoFleetScreen extends ConsumerWidget {
  const NoFleetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(actions: const [LanguageButton()]),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.badge_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              context.l10n.noFleetTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(context.l10n.noFleetBody, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => ref.read(authProvider.notifier).signOut(),
              child: Text(context.l10n.signOut),
            ),
          ],
        ),
      ),
    ),
  );
}
