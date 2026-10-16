import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/preferences.dart';
import 'app/providers.dart';
import 'core/db/database.dart';
import 'core/places/places_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerPlaceLicenses();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      // Screens show their own error + retry; no silent automatic retries.
      retry: (_, _) => null,
      overrides: [
        databaseProvider.overrideWithValue(AppDatabase.onDevice()),
        startupPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const TaxcyDriverApp(),
    ),
  );
}
