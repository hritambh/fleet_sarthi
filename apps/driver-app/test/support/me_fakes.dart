import 'package:taxcy_driver/core/api/json.dart';
import 'package:taxcy_driver/core/api/me_api.dart';
import 'package:taxcy_driver/core/api/models.dart';
import 'package:taxcy_driver/core/api/owner_models.dart';

import 'fakes.dart';
import 'owner_fakes.dart';

/// A driver's own document, as GET /me/documents returns it.
JsonMap myDocumentJson({
  String id = '0199c7a2-0000-7000-8000-000000000e01',
  String docType = 'driving_licence',
  String reviewStatus = 'approved',
  String? reviewNote,
  String? expiresOn = '2028-03-31',
}) => {
  'id': id,
  'docType': docType,
  'vehicleId': null,
  'driverId': driverId,
  'number': 'MH12 20200001234',
  'validFrom': null,
  'expiresOn': expiresOn,
  'mediaId': null,
  'mediaContentType': null,
  'files': <JsonMap>[],
  'supersededBy': null,
  'daysLeft': expiresOn == null ? null : 900,
  'status': 'valid',
  'reviewStatus': reviewStatus,
  'reviewNote': reviewNote,
  'submittedByDriver': true,
  'replacesId': null,
  'createdAt': '2026-10-01T05:00:00.000Z',
};

/// Serves the signed-in driver's profile, documents and trip history, and
/// records every call as `name args` (like [FakeOwnerApi]).
class FakeMeApi implements MeApi {
  final calls = <ApiCall>[];

  JsonMap driverJsonValue = driverJson(
    vehicles: [
      {'id': vehicleId, 'registrationNo': 'MH12AB1234'},
    ],
  );
  List<JsonMap> documentList = [myDocumentJson()];

  /// Served for any range.
  List<JsonMap> tripList = [];

  void _record(String name, [Map<String, Object?> args = const {}]) =>
      calls.add(ApiCall(name, args));

  ApiCall last(String name) => calls.lastWhere((c) => c.name == name);

  @override
  Future<Driver> driver() async {
    _record('driver');
    return Driver.fromJson(driverJsonValue);
  }

  @override
  Future<Driver> updateProfile(JsonMap body) async {
    _record('updateProfile', body);
    driverJsonValue = {...driverJsonValue, ...body};
    return Driver.fromJson(driverJsonValue);
  }

  @override
  Future<void> requestPhoneOtp(String phone) async =>
      _record('requestPhoneOtp', {'phone': phone});

  @override
  Future<String> changePhone(String phone, String code) async {
    _record('changePhone', {'phone': phone, 'code': code});
    driverJsonValue = {...driverJsonValue, 'phone': phone};
    return phone;
  }

  @override
  Future<List<FleetDocument>> documents() async {
    _record('documents');
    return documentList.map(FleetDocument.fromJson).toList();
  }

  @override
  Future<FleetDocument> submitDocument(JsonMap body) async {
    _record('submitDocument', body);
    final doc = myDocumentJson(
      id: '0199c7a2-0000-7000-8000-000000000e9${documentList.length}',
      docType: body['docType']! as String,
      reviewStatus: 'pending',
      expiresOn: body['expiresOn'] as String?,
    );
    documentList = [...documentList, doc];
    return FleetDocument.fromJson(doc);
  }

  @override
  Future<FleetDocument> renewDocument(String id, JsonMap body) async {
    _record('renewDocument', {'id': id, ...body});
    final doc = {
      ...myDocumentJson(
        id: '0199c7a2-0000-7000-8000-000000000e8${documentList.length}',
        reviewStatus: 'pending',
        expiresOn: body['expiresOn'] as String?,
      ),
      'replacesId': id,
    };
    documentList = [...documentList, doc];
    return FleetDocument.fromJson(doc);
  }

  @override
  Future<List<Trip>> tripsBetween(DateTime from, DateTime to) async {
    _record('tripsBetween', {
      'from': from.toUtc().toIso8601String(),
      'to': to.toUtc().toIso8601String(),
    });
    return tripList.map(Trip.fromJson).toList();
  }
}
