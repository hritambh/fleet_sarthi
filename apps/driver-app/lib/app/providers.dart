import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/api.dart';
import '../core/api/auth_api.dart';
import '../core/api/auth_models.dart';
import '../core/api/http_api.dart';
import '../core/api/models.dart';
import '../core/api/owner_api.dart';
import '../core/auth/session_store.dart';
import '../core/db/database.dart';
import '../core/location/gps.dart';
import '../core/media/camera_capture.dart';
import '../core/media/file_pick.dart';
import '../core/media/photo_store.dart';
import '../core/media/photo_store_platform.dart';
import '../core/repositories/fuel_repository.dart';
import '../core/repositories/trips_repository.dart';
import '../core/sync/sync_engine.dart';
import 'preferences.dart';
import 'workspaces.dart';

/// API server root, set at build time with `--dart-define=API_URL=...`. Defaults to
/// the local API as seen from an Android emulator, or from the browser on the web.
const apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000',
);

/// Sent at login so the server knows which kind of device holds the session.
String get devicePlatform => kIsWeb
    ? 'web'
    : defaultTargetPlatform == TargetPlatform.iOS
    ? 'ios'
    : 'android';

/// Overridden in main() with the on-device database, and in tests with an in-memory one.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

final sessionStoreProvider = Provider<SessionStore>(
  (ref) => SecureSessionStore(),
);

final httpApiProvider = Provider<HttpTaxcyApi>(
  (ref) => HttpTaxcyApi(
    baseUrl: apiUrl,
    sessions: ref.watch(sessionStoreProvider),
    onSignedOut: () => ref.invalidate(authProvider),
  ),
);

/// The driver endpoints (sync engine, repositories); tests replace it with a fake.
final apiProvider = Provider<TaxcyApi>((ref) => ref.watch(httpApiProvider));

/// Signing in and the account's sign-in methods; tests replace it with a fake.
final authApiProvider = Provider<AuthApi>(
  (ref) => HttpAuthApi(ref.watch(httpApiProvider)),
);

/// The signed-in user's account (whether a password is set).
final accountProvider = FutureProvider.autoDispose<Account>(
  (ref) => ref.watch(authApiProvider).account(),
);

/// The owner/manager endpoints (owner mode); tests replace it with a fake.
final ownerApiProvider = Provider<OwnerApi>(
  (ref) => HttpOwnerApi(ref.watch(httpApiProvider)),
);

final syncEngineProvider = Provider<SyncEngine>((ref) {
  final engine = SyncEngine(
    db: ref.watch(databaseProvider),
    api: ref.watch(apiProvider),
    readPhoto: ref.watch(photoStoreProvider).read,
    deviceId: ref.watch(sessionStoreProvider).deviceId,
  );
  ref.onDispose(engine.dispose);
  return engine;
});

final tripsRepositoryProvider = Provider<TripsRepository>(
  (ref) => TripsRepository(
    ref.watch(databaseProvider),
    ref.watch(syncEngineProvider),
  ),
);

final fuelRepositoryProvider = Provider<FuelRepository>(
  (ref) => FuelRepository(ref.watch(databaseProvider), ref.watch(apiProvider)),
);

/// The fleet's vehicles, refreshed when online and cached for offline use.
final vehiclesProvider = FutureProvider<List<Vehicle>>(
  (ref) => ref.watch(fuelRepositoryProvider).vehicles(),
);

/// Where photos wait until they're uploaded: files on phones, the local database
/// in the browser.
final photoStoreProvider = Provider<PhotoStore>(
  (ref) => platformPhotoStore(ref.watch(databaseProvider)),
);

/// How photos are taken; tests replace it with a fake.
final photoCaptureProvider = Provider<PhotoCapture>((ref) {
  final store = ref.watch(photoStoreProvider);
  return (context, kind) => captureWithCamera(context, kind, store);
});

/// How documents are picked from files; tests replace it with a fake.
final filePickProvider = Provider<FilePick>((ref) {
  final store = ref.watch(photoStoreProvider);
  return (kind) => pickDocumentFiles(store, kind);
});

/// Whether to run background sync and GPS (off in widget tests).
final backgroundWorkProvider = Provider<bool>((ref) => true);

final gpsRecorderProvider = Provider<GpsRecorder>((ref) {
  final recorder = GpsRecorder(ref.watch(databaseProvider));
  ref.onDispose(recorder.stop);
  return recorder;
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) async* {
  final engine = ref.watch(syncEngineProvider);
  yield engine.current;
  yield* engine.status;
});

final tripsProvider = StreamProvider<List<TripView>>(
  (ref) => ref.watch(tripsRepositoryProvider).watchTrips(),
);

final tripProvider = StreamProvider.family<TripView?, String>(
  (ref, id) => ref.watch(tripsRepositoryProvider).watchTrip(id),
);

final tripDistanceProvider = StreamProvider.family<double, String>((
  ref,
  tripId,
) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.gpsPoints,
  )..where((p) => p.tripId.equals(tripId))).watch().map(trackKm);
});

/// The signed-in session (null when signed out).
final authProvider = AsyncNotifierProvider<AuthController, Session?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<Session?> {
  @override
  Future<Session?> build() => ref.watch(sessionStoreProvider).load();

  DeviceInfo? _deviceInfo;

  Future<DeviceInfo> _device() async => _deviceInfo ??= (
    deviceId: await ref.read(sessionStoreProvider).deviceId(),
    platform: devicePlatform,
  );

  AuthApi get _api => ref.read(authApiProvider);

  Future<void> _signedIn(Session session) async {
    await ref.read(sessionStoreProvider).save(session);
    state = AsyncData(session);
  }

  /// Sends a password-reset code (printed in the API log locally and in demo
  /// mode).
  Future<OtpTicket> requestOtp(String phone) => _api.requestOtp(phone);

  Future<void> passwordLogin(String phone, String password) async => _signedIn(
    await _api.passwordLogin(
      phone: phone,
      password: password,
      device: await _device(),
    ),
  );

  Future<void> signUp({
    required String phone,
    required String password,
    String? name,
    String? verificationToken,
  }) async => _signedIn(
    await _api.signUp(
      phone: phone,
      password: password,
      name: name,
      verificationToken: verificationToken,
      device: await _device(),
    ),
  );

  /// Whether [phone] has an account to log in to with an OTP.
  Future<bool> phoneOtpCheck(String phone) => _api.phoneOtpCheck(phone);

  /// Signs in with a number verified by OTP (no password); [phone] is the
  /// number entered, which the verified one must match.
  Future<void> phoneOtpLogin(String verificationToken, {String? phone}) async =>
      _signedIn(
        await _api.phoneOtpLogin(
          verificationToken: verificationToken,
          phone: phone,
          device: await _device(),
        ),
      );

  /// Sets a new password for the number verified by OTP, and signs in.
  Future<void> resetPasswordVerified({
    required String verificationToken,
    required String password,
  }) async => _signedIn(
    await _api.resetPasswordVerified(
      verificationToken: verificationToken,
      password: password,
      device: await _device(),
    ),
  );

  Future<void> resetPassword({
    required String phone,
    required String code,
    required String password,
  }) async => _signedIn(
    await _api.resetPassword(
      phone: phone,
      code: code,
      password: password,
      device: await _device(),
    ),
  );

  /// Opens [workspace]: its owner or driver screens, in its fleet. Moving to
  /// another fleet gets a session there and clears this device's trips and
  /// queue, which belong to the old fleet; it throws [UnsyncedWorkException]
  /// while some of that hasn't reached the server.
  Future<void> open(Workspace workspace) async {
    final session = state.value;
    if (session == null) return;
    if (workspace.orgId != session.activeOrgId) {
      await _leaveFleet();
      await _signedIn(await _api.switchOrg(workspace.orgId));
    }
    ref.read(appModeProvider.notifier).set(workspace.mode);
  }

  /// Creates a fleet the user owns and opens it in owner mode. [alsoDrives]
  /// makes it a DCO (owner-driver), so they can drive its vehicles too.
  Future<void> createFleet({
    required String name,
    required bool alsoDrives,
  }) async {
    await _leaveFleet();
    await _signedIn(
      await _api.createOrg(name: name, kind: alsoDrives ? 'dco' : 'fleet'),
    );
    ref.read(appModeProvider.notifier).set(AppMode.owner);
  }

  /// Picks up fleets that added this user since they signed in. Someone who
  /// had none is taken into the first (one they run, else one they drive
  /// for). False when there's still none.
  Future<bool> refreshFleets() async {
    final session = state.value;
    if (session == null) return false;
    final updated = session.withMemberships(await _api.memberships());
    final workspaces = workspacesFor(updated);
    if (workspaces.isEmpty) return false;
    if (session.activeOrgId != null) {
      await _signedIn(updated);
    } else {
      await open(workspaces.first);
    }
    return true;
  }

  /// Sends what's waiting, then clears this fleet's data off the device.
  Future<void> _leaveFleet() async {
    final db = ref.read(databaseProvider);
    if (ref.read(backgroundWorkProvider)) {
      try {
        await ref.read(syncEngineProvider).syncNow();
      } on Object {
        // Offline: the count below decides.
      }
    }
    final left = await db.unsyncedWork();
    if (left > 0) throw UnsyncedWorkException(left);
    await ref.read(gpsRecorderProvider).stop();
    await db.clearAll();
  }

  Future<void> signOut() async {
    final store = ref.read(sessionStoreProvider);
    final session = await store.load();
    if (session != null) {
      try {
        await _api.logout(session.refreshToken);
      } on ApiException {
        // Signing out locally still matters when offline.
      }
    }
    await ref.read(gpsRecorderProvider).stop();
    await store.clear();
    await ref.read(databaseProvider).clearAll();
    state = const AsyncData(null);
  }
}
