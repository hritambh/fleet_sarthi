import 'package:flutter/material.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../common/format.dart';
import '../common/language_picker.dart';
import 'auth_forms.dart';
import 'login_illustration.dart';

/// Signing in: mobile number + password, plus sign-up and forgot password.
/// Every step lives in the same card, so a successful sign-in just replaces
/// this screen.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    this.initialFlow = LoginFlow.password,
    this.onAbout,
    super.key,
  });

  /// Which step opens first (sign up when coming from "Get started").
  final LoginFlow initialFlow;

  /// Goes back to the welcome page; no link when null.
  final VoidCallback? onAbout;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Shared by every step, so the number typed once carries over.
  final _phone = TextEditingController();
  late LoginFlow _flow = widget.initialFlow;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _open(LoginFlow flow) => setState(() => _flow = flow);

  /// From this width the page splits in two: the form, and an illustration.
  static const _splitMinWidth = 900.0;

  @override
  Widget build(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _splitMinWidth
      ? _split(context)
      : _narrow(context);

  /// Wide screens: the sign-in card on the left, a picture on the right, and
  /// a line about the company at the bottom right.
  Widget _split(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      key: const Key('login-split'),
      backgroundColor: context.tc.background,
      body: Row(
        children: [
          Container(
            width: 520,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.tc.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.tc.blue100),
              boxShadow: [
                BoxShadow(
                  color: TaxcyColors.blue900.withValues(alpha: 0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SafeArea(
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: TaxcyColors.blue700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_taxi,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l.appTitle,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: context.tc.blue950,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: _form(),
                      ),
                    ),
                    if (widget.onAbout case final onAbout?)
                      Center(
                        child: TextButton.icon(
                          key: const Key('login-about'),
                          onPressed: onAbout,
                          icon: const Icon(Icons.info_outline, size: 18),
                          label: Text(l.welcomeAbout),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'v$appVersion',
                        key: const Key('login-version'),
                        style: TextStyle(color: context.tc.muted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                const LoginIllustrationPanel(),
                Positioned(
                  top: 20,
                  right: 24,
                  child: LanguageButton(color: context.tc.blue800),
                ),
                Positioned(
                  right: 28,
                  bottom: 22,
                  width: 460,
                  child: Text(
                    '© ${DateTime.now().year} ${l.appTitle}. '
                    '${l.loginAboutCompany}',
                    key: const Key('login-company'),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      color: context.tc.muted,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _narrow(BuildContext context) {
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
                          color: context.tc.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.local_taxi,
                          color: context.tc.blue700,
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
                  if (widget.onAbout case final onAbout?)
                    Center(
                      child: TextButton.icon(
                        key: const Key('login-about'),
                        onPressed: onAbout,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: Text(context.l10n.welcomeAbout),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'v$appVersion',
                      key: const Key('login-version'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
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
