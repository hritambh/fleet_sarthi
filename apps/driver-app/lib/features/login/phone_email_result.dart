/// The access token in phone.email's web-plugin result
/// ("https://user.phone.email/user_TOKEN.json"); null for anything else.
String? accessTokenFromUserJsonUrl(Object? url) {
  if (url is! String) return null;
  final match = RegExp(
    r'^https://user\.phone\.email/user_([^/]+)\.json$',
  ).firstMatch(url);
  return match?.group(1);
}
