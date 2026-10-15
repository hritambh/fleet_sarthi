// The Indian cities and towns a trip can run between, bundled with the app
// (assets/data/in_cities.json, built by tool/generate_cities.mjs from the
// GeoNames India dump). Loaded once and filtered in memory: no geocoder, no
// network call per keystroke, and it works offline.
import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/api/models.dart';

const _asset = 'assets/data/in_cities.json';

/// How many matches to offer at once.
const citySuggestionLimit = 8;

class City {
  const City({required this.name, required this.state, required this.point});

  final String name;
  final String state;
  final GeoPoint point;

  /// What goes into the trip's pickup or drop, e.g. "Pune, Maharashtra".
  String get label => '$name, $state';
}

/// The bundled list, most populous first, read from the asset on first use.
class Cities {
  Cities._(this.all);

  static Cities? _loaded;

  /// A list given directly, for tests and for a caller with its own.
  factory Cities.of(List<City> cities) = Cities._;

  final List<City> all;

  static Future<Cities> load([AssetBundle? bundle]) async {
    final already = _loaded;
    if (already != null) return already;
    final raw = await (bundle ?? rootBundle).loadString(_asset);
    final rows = (jsonDecode(raw) as List<dynamic>).cast<List<dynamic>>();
    final cities = [
      for (final row in rows)
        City(
          name: row[0] as String,
          state: row[1] as String,
          point: GeoPoint(
            (row[2] as num).toDouble(),
            (row[3] as num).toDouble(),
          ),
        ),
    ];
    return _loaded = Cities._(cities);
  }

  /// Forgets the loaded list. Tests use it to load a different one.
  static void reset() => _loaded = null;

  /// The best matches for what has been typed: cities whose name starts with it
  /// first, then ones that merely contain it, each in population order, since
  /// typing "pun" should offer Pune before Punalur.
  List<City> search(String query, {int limit = citySuggestionLimit}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final starts = <City>[];
    final contains = <City>[];
    for (final city in all) {
      final name = city.name.toLowerCase();
      if (name.startsWith(q)) {
        starts.add(city);
      } else if (name.contains(q) || city.state.toLowerCase().startsWith(q)) {
        contains.add(city);
      }
      if (starts.length >= limit) break;
    }
    return [...starts, ...contains].take(limit).toList();
  }
}
