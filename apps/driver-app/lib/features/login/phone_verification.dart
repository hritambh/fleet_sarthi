import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/api/auth_models.dart';
import '../common/format.dart';

/// Which sign-in methods the server offers. If it can't be asked (offline, an
/// older API), the app sticks to passwords and reset codes.
final authMethodsProvider = FutureProvider<AuthMethods>((ref) async {
  try {
    return await ref.watch(authApiProvider).methods();
  } on Object {
    return AuthMethods.none;
  }
});

/// The phone OTP this device can use, or null (switched off on the server, or
/// phone.email on the web, which its sign-in screen doesn't support).
PhoneOtpMethod? usablePhoneOtp(WidgetRef ref) {
  final otp = ref.watch(authMethodsProvider).value?.phoneOtp;
  if (otp == null) return null;
  return ref.watch(phoneVerifierProvider).supports(otp) ? otp : null;
}

/// Proves the user owns a number with an OTP and returns the provider's
/// verification token for the API to check, or null if they backed out.
abstract class PhoneVerifier {
  bool supports(PhoneOtpMethod otp);

  /// [phoneHint] is the 10-digit number already typed, if any.
  Future<String?> verify(
    BuildContext context,
    PhoneOtpMethod otp, {
    required String deviceId,
    String phoneHint = '',
  });
}

/// Tests replace it with a fake.
final phoneVerifierProvider = Provider<PhoneVerifier>(
  (ref) => const AppPhoneVerifier(),
);

class AppPhoneVerifier implements PhoneVerifier {
  const AppPhoneVerifier();

  @override
  bool supports(PhoneOtpMethod otp) => switch (otp.provider) {
    'stub' => true,
    // phone.email's sign-in screen runs in a native WebView (Android, iOS).
    'phone_email' =>
      otp.clientId != null &&
          !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS),
    _ => false,
  };

  @override
  Future<String?> verify(
    BuildContext context,
    PhoneOtpMethod otp, {
    required String deviceId,
    String phoneHint = '',
  }) => switch (otp.provider) {
    'phone_email' => Navigator.of(context).push<String>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            PhoneEmailScreen(clientId: otp.clientId!, deviceId: deviceId),
      ),
    ),
    _ => showDialog<String>(
      context: context,
      builder: (_) => _StubVerifyDialog(phoneHint: phoneHint),
    ),
  };
}

/// phone.email's sign-in page: the user enters their number and the OTP it
/// sends; the page then hands the app an access token, which the API exchanges
/// with phone.email for the verified number. Pops the token, or null.
class PhoneEmailScreen extends StatefulWidget {
  const PhoneEmailScreen({
    required this.clientId,
    required this.deviceId,
    super.key,
  });

  final String clientId;
  final String deviceId;

  /// The page phone.email's own Flutter package loads (auth_type 5 = app).
  static Uri signInUrl(String clientId, String deviceId) => Uri.https(
    'auth.phone.email',
    '/log-in',
    {'client_id': clientId, 'device': deviceId, 'auth_type': '5'},
  );

  @override
  State<PhoneEmailScreen> createState() => _PhoneEmailScreenState();
}

class _PhoneEmailScreenState extends State<PhoneEmailScreen> {
  var _loading = true;
  String? _error;

  void _done(String? token) {
    if (mounted) Navigator.of(context).pop(token);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.phoneVerifyTitle)),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri.uri(
                PhoneEmailScreen.signInUrl(widget.clientId, widget.deviceId),
              ),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              cacheEnabled: false,
            ),
            onWebViewCreated: (controller) => controller.addJavaScriptHandler(
              // The page calls this with {access_token, jwt, ...} once the
              // OTP is verified.
              handlerName: 'sendTokenToApp',
              callback: (args) {
                final data = args.isEmpty ? null : args.first;
                final token = data is Map ? data['access_token'] : null;
                _done(token is String && token.isNotEmpty ? token : null);
              },
            ),
            onLoadStop: (_, _) => setState(() => _loading = false),
            onReceivedError: (_, request, _) {
              if (request.isForMainFrame ?? true) {
                setState(() => _error = l.errorNetwork);
              }
            },
          ),
          if (_loading && _error == null)
            const Center(child: CircularProgressIndicator()),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _done(null),
                      child: Text(l.close),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// PHONE_OTP_PROVIDER=stub (development and tests): no SMS; the number typed
/// here counts as verified.
class _StubVerifyDialog extends StatefulWidget {
  const _StubVerifyDialog({required this.phoneHint});
  final String phoneHint;

  @override
  State<_StubVerifyDialog> createState() => _StubVerifyDialogState();
}

class _StubVerifyDialogState extends State<_StubVerifyDialog> {
  late final _phone = TextEditingController(text: widget.phoneHint);

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.phoneVerifyTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.stubVerifyHint),
          const SizedBox(height: 12),
          TextField(
            key: const Key('stub-verify-phone'),
            controller: _phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: InputDecoration(
              labelText: l.mobileNumber,
              prefixText: '+91 ',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(
          key: const Key('stub-verify'),
          onPressed: () =>
              Navigator.of(context).pop('stub:+91${_phone.text.trim()}'),
          child: Text(l.verify),
        ),
      ],
    );
  }
}
