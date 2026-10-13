/// No popup outside the browser; the native apps use PhoneEmailScreen.
const phoneEmailPopupSupported = false;

/// The browser blocked the sign-in popup.
class PopupBlockedException implements Exception {
  const PopupBlockedException();
}

Future<String?> openPhoneEmailPopup(String clientId, {String phoneHint = ''}) =>
    throw UnsupportedError('phone.email popup is web only');
