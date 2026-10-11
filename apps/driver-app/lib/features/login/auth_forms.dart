import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../common/format.dart';
import 'auth_widgets.dart';

/// The login screen's steps. Each is a form inside the same card, so signing in
/// from any of them simply replaces the login screen.
enum LoginFlow { password, signUp, reset }

typedef OpenFlow = void Function(LoginFlow flow);

const _gap = SizedBox(height: 16);

Widget _intro(BuildContext context, String text, {String? title}) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    if (title != null) ...[
      Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
    ],
    Text(text, style: Theme.of(context).textTheme.bodyLarge),
    const SizedBox(height: 24),
  ],
);

/// Mobile number + password: the default way in.
class PasswordLoginForm extends ConsumerStatefulWidget {
  const PasswordLoginForm({
    required this.phone,
    required this.onOpen,
    super.key,
  });

  final TextEditingController phone;
  final OpenFlow onOpen;

  @override
  ConsumerState<PasswordLoginForm> createState() => _PasswordLoginFormState();
}

class _PasswordLoginFormState extends ConsumerState<PasswordLoginForm>
    with AuthFormState {
  final _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    final invalid = mobileError(l, widget.phone.text);
    if (invalid != null) return showError(invalid);
    if (_password.text.isEmpty) return showError(l.enterPassword);
    await run(
      () => auth.passwordLogin(indianE164(widget.phone.text), _password.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _intro(context, l.loginIntro),
          PhoneField(controller: widget.phone, enabled: !busy),
          _gap,
          PasswordField(
            key: const Key('password-field'),
            controller: _password,
            label: l.password,
            enabled: !busy,
            onSubmitted: _submit,
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FormLink(
              key: const Key('go-forgot'),
              label: l.forgotPassword,
              onPressed: busy ? null : () => widget.onOpen(LoginFlow.reset),
            ),
          ),
          if (error != null) FormError(error!),
          const SizedBox(height: 8),
          SubmitButton(label: l.logIn, busy: busy, onPressed: _submit),
          const SizedBox(height: 8),
          FormLink(
            key: const Key('go-sign-up'),
            label: l.newHereSignUp,
            onPressed: busy ? null : () => widget.onOpen(LoginFlow.signUp),
          ),
        ],
      ),
    );
  }
}

/// New password and its confirmation.
List<Widget> _newPasswordFields(
  BuildContext context, {
  required TextEditingController password,
  required TextEditingController again,
  required bool enabled,
  required VoidCallback onSubmitted,
}) => [
  _gap,
  PasswordField(
    key: const Key('new-password-field'),
    controller: password,
    label: context.l10n.newPassword,
    helper: context.l10n.passwordHint,
    isNew: true,
    enabled: enabled,
  ),
  _gap,
  PasswordField(
    key: const Key('confirm-password-field'),
    controller: again,
    label: context.l10n.confirmPassword,
    isNew: true,
    enabled: enabled,
    onSubmitted: onSubmitted,
  ),
];

/// Mobile number + name (optional) + password twice → signed in. An invited
/// number joins its fleet.
class SignUpForm extends ConsumerStatefulWidget {
  const SignUpForm({required this.phone, required this.onOpen, super.key});

  final TextEditingController phone;
  final OpenFlow onOpen;

  @override
  ConsumerState<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends ConsumerState<SignUpForm> with AuthFormState {
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _again = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    _again.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    final invalid =
        mobileError(l, widget.phone.text) ??
        newPasswordError(l, _password.text, _again.text);
    if (invalid != null) return showError(invalid);
    final name = _name.text.trim();
    await run(
      () => auth.signUp(
        phone: indianE164(widget.phone.text),
        password: _password.text,
        name: name.isEmpty ? null : name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _intro(context, l.signUpIntro, title: l.signUpTitle),
          PhoneField(controller: widget.phone, enabled: !busy),
          _gap,
          TextField(
            key: const Key('name-field'),
            controller: _name,
            enabled: !busy,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            decoration: InputDecoration(
              labelText: l.yourNameOptional,
              border: const OutlineInputBorder(),
            ),
          ),
          ..._newPasswordFields(
            context,
            password: _password,
            again: _again,
            enabled: !busy,
            onSubmitted: _submit,
          ),
          if (error != null) FormError(error!),
          if (errorCode == 'ACCOUNT_EXISTS') ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  key: const Key('account-exists-log-in'),
                  onPressed: () => widget.onOpen(LoginFlow.password),
                  child: Text(l.logIn),
                ),
                OutlinedButton(
                  key: const Key('account-exists-reset'),
                  onPressed: () => widget.onOpen(LoginFlow.reset),
                  child: Text(l.resetPassword),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SubmitButton(label: l.createAccount, busy: busy, onPressed: _submit),
          FormLink(
            key: const Key('go-log-in'),
            label: l.haveAccountLogIn,
            onPressed: busy ? null : () => widget.onOpen(LoginFlow.password),
          ),
        ],
      ),
    );
  }
}

/// Forgot password: mobile number → reset code + new password → signed in.
/// Locally and in demo mode the API prints the code in its log.
class ResetPasswordForm extends ConsumerStatefulWidget {
  const ResetPasswordForm({
    required this.phone,
    required this.onOpen,
    super.key,
  });

  final TextEditingController phone;
  final OpenFlow onOpen;

  @override
  ConsumerState<ResetPasswordForm> createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends ConsumerState<ResetPasswordForm>
    with AuthFormState {
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _again = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    _password.dispose();
    _again.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l = context.l10n;
    final invalid =
        codeError(l, _code.text) ??
        newPasswordError(l, _password.text, _again.text);
    if (invalid != null) return showError(invalid);
    await run(
      () => auth.resetPassword(
        phone: indianE164(widget.phone.text),
        code: _code.text.trim(),
        password: _password.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _intro(
            context,
            codeSent
                ? l.loginCodeSent(phone: '+91 ${widget.phone.text.trim()}')
                : l.resetPasswordIntro,
            title: l.resetPasswordTitle,
          ),
          PhoneField(controller: widget.phone, enabled: !codeSent && !busy),
          if (codeSent) ...[
            _gap,
            CodeField(controller: _code, enabled: !busy),
            ..._newPasswordFields(
              context,
              password: _password,
              again: _again,
              enabled: !busy,
              onSubmitted: _submit,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            l.resetCodeInApiLog,
            key: const Key('reset-code-hint'),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: TaxcyColors.muted),
          ),
          if (error != null) FormError(error!),
          const SizedBox(height: 24),
          SubmitButton(
            label: codeSent ? l.saveAndLogIn : l.sendCode,
            busy: busy,
            onPressed: codeSent ? _submit : () => sendCode(widget.phone.text),
          ),
          if (codeSent) ...[
            ResendCodeButton(
              secondsLeft: resendIn,
              onPressed: busy
                  ? null
                  : () => sendCode(widget.phone.text, resend: true),
            ),
            FormLink(
              label: l.useDifferentNumber,
              onPressed: busy
                  ? null
                  : () {
                      _code.clear();
                      changeNumber();
                    },
            ),
          ],
          FormLink(
            key: const Key('go-log-in'),
            label: l.backToLogIn,
            onPressed: busy ? null : () => widget.onOpen(LoginFlow.password),
          ),
        ],
      ),
    );
  }
}
