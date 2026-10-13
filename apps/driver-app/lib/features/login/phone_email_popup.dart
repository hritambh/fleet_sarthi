// phone.email's website sign-in, for the web build (a popup window); the
// native apps use PhoneEmailScreen's WebView instead.
export 'phone_email_popup_io.dart'
    if (dart.library.js_interop) 'phone_email_popup_web.dart';
