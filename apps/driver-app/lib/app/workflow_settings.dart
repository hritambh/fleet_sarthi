import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/api/json.dart';
import '../core/api/models.dart';
import 'preferences.dart';
import 'providers.dart';

const _cacheKey = 'workflow_settings_v1';

String _keyFor(String? orgId) => '$_cacheKey:${orgId ?? '-'}';

WorkflowSettings? _cached(Ref ref, String? orgId) {
  final text = ref.read(startupPreferencesProvider)?.getString(_keyFor(orgId));
  if (text == null) return null;
  try {
    return WorkflowSettings.fromJson(asJsonMap(jsonDecode(text)));
  } on Object {
    return null;
  }
}

/// The active fleet's operating rules, fetched from the API. The last copy is
/// kept per fleet, so driver mode still knows them offline; with no copy yet
/// it assumes [WorkflowSettings.defaults]. Never fails: the API enforces the
/// real rules anyway (a refused action is reported like any other error).
final workflowSettingsProvider = FutureProvider<WorkflowSettings>((ref) async {
  final orgId = ref.watch(authProvider.select((s) => s.value?.activeOrgId));
  if (orgId == null) return WorkflowSettings.defaults;
  try {
    final fresh = await ref.watch(apiProvider).workflowSettings();
    await ref
        .read(startupPreferencesProvider)
        ?.setString(_keyFor(orgId), jsonEncode(fresh.toJson()));
    return fresh;
  } on Object {
    return _cached(ref, orgId) ?? WorkflowSettings.defaults;
  }
});

/// The rules screens use straight away: the fetched ones, else the copy kept
/// on the device, else the defaults.
final workflowRulesProvider = Provider<WorkflowSettings>((ref) {
  final fetched = ref.watch(workflowSettingsProvider).value;
  if (fetched != null) return fetched;
  final orgId = ref.watch(authProvider.select((s) => s.value?.activeOrgId));
  return _cached(ref, orgId) ?? WorkflowSettings.defaults;
});
