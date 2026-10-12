import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

const phoneEmailPopupSupported = true;

/// The browser blocked the sign-in popup.
class PopupBlockedException implements Exception {
  const PopupBlockedException();
}

/// Where web/phone-otp.html leaves the result, in case the popup closes
/// before its message arrives.
const _resultKey = 'phone-otp-result';

/// Opens phone.email's website sign-in in a popup. After the OTP, phone.email
/// sends the popup to our phone-otp.html with ?access_token=…, which posts the
/// token back to this window (same origin only) and closes. Returns the token,
/// or null if the user closed the popup.
Future<String?> openPhoneEmailPopup(String clientId) {
  final window = web.window;
  final origin = window.location.origin;
  web.window.localStorage.removeItem(_resultKey);
  final url = Uri.https('www.phone.email', '/auth/log-in', {
    'client_id': clientId,
    'redirect_url': '$origin/phone-otp.html',
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
  void finish(String? token) {
    if (done.isCompleted) return;
    window.removeEventListener('message', onMessage);
    watch?.cancel();
    window.localStorage.removeItem(_resultKey);
    done.complete(token == null || token.isEmpty ? null : token);
  }

  onMessage = ((web.MessageEvent e) {
    if (e.origin != origin) return;
    final data = e.data.dartify();
    if (data is Map && data['type'] == 'phone-otp') {
      finish(data['accessToken'] as String?);
    }
  }).toJS;
  window.addEventListener('message', onMessage);
  // Notice the popup closing: either the user gave up, or it finished and its
  // message is still in flight (then the stored result has the token).
  watch = Timer.periodic(const Duration(milliseconds: 500), (_) {
    if (!popup.closed) return;
    final stored = window.localStorage.getItem(_resultKey);
    final result = stored == null ? null : jsonDecode(stored);
    finish(result is Map ? result['accessToken'] as String? : null);
  });
  return done.future;
}
