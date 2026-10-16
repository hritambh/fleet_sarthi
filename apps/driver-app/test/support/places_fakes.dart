import 'dart:async';

import 'package:taxcy_driver/core/places/places_api.dart';

/// Stands in for the place search: records what was asked and answers with
/// [results], once [gate] (when set) completes, like a slow server.
class FakePlacesApi implements PlacesApi {
  final queries = <String>[];
  List<PlaceSuggestion> results = const [];
  Completer<void>? gate;

  @override
  Future<List<PlaceSuggestion>> search(String query) async {
    queries.add(query);
    await gate?.future;
    return results;
  }
}
