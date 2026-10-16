import 'package:flutter/foundation.dart';

import '../api/http_api.dart';
import '../api/json.dart';
import '../api/models.dart';

/// A place to suggest for a pickup or drop (`GET /places/search`).
class PlaceSuggestion {
  const PlaceSuggestion({
    required this.label,
    required this.point,
    this.detail,
  });

  factory PlaceSuggestion.fromJson(JsonMap json) => PlaceSuggestion(
    label: json.str('label'),
    detail: json['detail'] as String?,
    point: GeoPoint(
      (json['lat'] as num).toDouble(),
      (json['lng'] as num).toDouble(),
    ),
  );

  /// What goes in the field when it's picked: a town ("Lonavala"), or a
  /// locality with its town ("Hinjawadi Phase 1, Pune").
  final String label;

  /// The line under it: the state.
  final String? detail;
  final GeoPoint point;
}

/// Place suggestions for the pickup and drop fields. The server asks
/// Geoapify (OpenStreetMap data) and caches the answers for everyone.
abstract class PlacesApi {
  /// Fewer letters than this, and nothing is asked.
  static const minLetters = 3;

  /// Places in India matching [query]; empty when there are none, place
  /// search is off, or the phone is offline. Never throws.
  Future<List<PlaceSuggestion>> search(String query);
}

class HttpPlacesApi implements PlacesApi {
  HttpPlacesApi(this._http);
  final HttpTaxcyApi _http;

  /// The last answers this session, so backspacing and retyping costs nothing.
  final _cache = <String, List<PlaceSuggestion>>{};
  static const _cacheSize = 50;

  @override
  Future<List<PlaceSuggestion>> search(String query) async {
    final key = query.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    if (key.replaceAll(' ', '').length < PlacesApi.minLetters) return const [];
    final cached = _cache.remove(key);
    if (cached != null) return _cache[key] = cached;
    try {
      final found = jsonList(
        await _http.send('GET', '/places/search', query: {'q': key}),
      ).map(PlaceSuggestion.fromJson).toList();
      if (_cache.length >= _cacheSize) _cache.remove(_cache.keys.first);
      return _cache[key] = found;
    } on Object catch (e) {
      debugPrint('place search failed: $e');
      return const [];
    }
  }
}

/// Credits the place data on the app's licences page, as its terms ask.
void registerPlaceLicenses() {
  LicenseRegistry.addLicense(
    () => Stream.fromIterable(const [
      LicenseEntryWithLineBreaks(
        ['Geoapify', 'OpenStreetMap'],
        'Pickup and drop suggestions are powered by Geoapify '
        '(https://www.geoapify.com) and are © OpenStreetMap contributors, '
        'available under the Open Database License '
        '(https://www.openstreetmap.org/copyright).',
      ),
    ]),
  );
}
