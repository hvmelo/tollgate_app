import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tollgate_app/config/app_config.dart';

import 'core/providers/core_providers.dart';
import 'main.dart';
import 'utils/provider_logger.dart';

/// Staging config entry point.
/// Launch with `flutter run --target lib/main_staging.dart`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration for staging mode with real implementations
  AppConfig.init(environment: AppEnvironment.staging, useMocks: false);

  // Initialize the shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Create a provider container with overrides
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
      // No mock overrides for staging - we use real implementations
    ],
    observers: [ProviderLogger()],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MainApp(),
    ),
  );
}
