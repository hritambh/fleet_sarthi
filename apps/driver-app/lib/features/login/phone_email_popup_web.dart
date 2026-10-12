import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'phone_email_result.dart';

const phoneEmailPopupSupported = true;

/// The browser blocked the sign-in popup.
class PopupBlockedException implements Exception {
  const PopupBlockedException();
}

/// Where web/phone-otp.html leaves a token if phone.email ever returns
/// through redirect_url instead of messaging this window.
const _resultKey = 'phone-otp-result';

/// phone.email's sign-in page, which messages this window with the result.
const _phoneEmailOrigin = 'https://auth.phone.email';

/// How long to keep listening after the popup closes: phone.email posts the
/// result and closes the popup at once, so the message can arrive just after.
const _closeGrace = Duration(milliseconds: 1500);

/// Opens phone.email's website sign-in in a popup, in its "web plugin" mode
/// (auth_type 8): after the OTP the popup posts
/// {user_json_url: https://user.phone.email/user_ACCESS-TOKEN.json} to this
/// window and closes, without navigating this window away. Returns the access
/// token (the API checks it with phone.email), or null if the user closed the
/// popup.
Future<String?> openPhoneEmailPopup(String clientId) {
  final window = web.window;
  final origin = window.location.origin;
  window.localStorage.removeItem(_resultKey);
  final url = Uri.https('www.phone.email', '/auth/log-in', {
    'client_id': clientId,
    'redirect_url': '$origin/phone-otp.html',
    'auth_type': '8',
  });
  // Centred, the size phone.email's own snippet uses.
  const width = 500;
  const height = 560;
  final left = window.screenX + (window.outerWidth - width) ~/ 2;
  final top = window.screenY + (window.outerHeight - height) ~/ 2;
  final popup = window.open(
    url.toString(),
    'peLoginWindow',
    'toolbar=0,scrollbars=0,menubar=0,status=0,resizable=0,'
        'width=$width,height=$height,left=$left,top=$top',
  );
  if (popup == null) throw const PopupBlockedException();

  final done = Completer<String?>();
  late final JSFunction onMessage;
  Timer? watch;
  Timer? grace;
  void finish(String? token) {
    if (done.isCompleted) return;
    window.removeEventListener('message', onMessage);
    watch?.cancel();
    grace?.cancel();
    window.localStorage.removeItem(_resultKey);
    done.complete(token == null || token.isEmpty ? null : token);
  }

  onMessage = ((web.MessageEvent e) {
    final data = e.data.dartify();
    if (data is! Map) return;
    if (e.origin == _phoneEmailOrigin) {
      finish(accessTokenFromUserJsonUrl(data['user_json_url']));
    } else if (e.origin == origin && data['type'] == 'phone-otp') {
      finish(data['accessToken'] as String?); // via phone-otp.html
    }
  }).toJS;
  window.addEventListener('message', onMessage);
  watch = Timer.periodic(const Duration(milliseconds: 500), (_) {
    if (!popup.closed || grace != null) return;
    grace = Timer(_closeGrace, () {
      final stored = window.localStorage.getItem(_resultKey);
      final result = stored == null ? null : jsonDecode(stored);
      finish(result is Map ? result['accessToken'] as String? : null);
    });
  });
  return done.future;
}
