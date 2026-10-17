import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:taxcy_driver/core/api/http_api.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/core/auth/session_store.dart';
import 'package:taxcy_driver/core/places/places_api.dart';

import 'support/fakes.dart';

HttpPlacesApi placesApi(MockClientHandler handler) => HttpPlacesApi(
  HttpTaxcyApi(
    baseUrl: 'http://api.test',
    sessions: InMemorySessionStore(Session.fromJson(sessionJson())),
    client: MockClient(handler),
  ),
);

void main() {
  const body = '''
[{"label": "Hinjawadi Phase 1, Pune", "detail": "Maharashtra",
  "lat": 18.5912, "lng": 73.7389, "source": "ola"},
 {"label": "Goa", "detail": null, "lat": 15.3, "lng": 74}]''';

  test('asks our API once per query and keeps the answer', () async {
    final asked = <Uri>[];
    final api = placesApi((req) async {
      asked.add(req.url);
      return http.Response(body, 200);
    });
    final found = await api.search('Hinjewadi  Ph');
    expect(found.map((s) => s.label), ['Hinjawadi Phase 1, Pune', 'Goa']);
    expect(found.first.detail, 'Maharashtra');
    expect(found.first.point.lat, 18.5912);
    expect(found.last.detail, isNull);
    expect(found.last.point.lng, 74);
    expect(found.first.source, PlaceSource.ola);
    // No source (a server from before Ola Maps): Geoapify's.
    expect(found.last.source, PlaceSource.geoapify);

    expect(await api.search(' hinjewadi ph'), hasLength(2));
    expect(asked, hasLength(1));
    expect(asked.single.path, '/v1/places/search');
    expect(asked.single.queryParameters['q'], 'hinjewadi ph');
  });

  test('errors and short queries give nothing', () async {
    var calls = 0;
    final offline = placesApi((_) async {
      calls++;
      throw const SocketException('offline');
    });
    expect(await offline.search('hinjewadi'), isEmpty);
    expect(await offline.search('hi'), isEmpty);
    expect(calls, 1);
    final down = placesApi((_) async => http.Response('busy', 503));
    expect(await down.search('hinjewadi'), isEmpty);
  });
}
