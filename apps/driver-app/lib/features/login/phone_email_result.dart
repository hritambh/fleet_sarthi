/// The access token in phone.email's web-plugin result
/// ("https://user.phone.email/user_TOKEN.json"); null for anything else.
String? accessTokenFromUserJsonUrl(Object? url) {
  if (url is! String) return null;
  final match = RegExp(
    r'^https://user\.phone\.email/user_([^/]+)\.json$',
  ).firstMatch(url);
  return match?.group(1);
}

/// Query parameters that make phone.email ask for a number and send a fresh
/// OTP every time. Without `mode=othernum`, a browser or device that verified
/// a number before gets phone.email's "Choose Phone Number" page, where one tap
/// on Continue reuses that number without any OTP (on a shared device, the
/// previous user's). `user_phone_no` pre-fills the number typed in our form.
Map<String, String> freshOtpParams(String phoneHint) => {
  'mode': 'othernum',
  if (RegExp(r'^[6-9]\d{9}$').hasMatch(phoneHint)) 'user_phone_no': phoneHint,
};
