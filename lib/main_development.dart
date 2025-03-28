import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/environment/environment_config.dart';
import 'config/environment/environment_provider.dart';
import 'config/storage/shared_preferences_provider.dart';
import 'main.dart';
import 'config/logging/provider_logger.dart';

/// Development config entry point.
/// Launch with `flutter run --target lib/main_development.dart`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration for development mode
  final env = EnvironmentConfig.development();

  // Initialize the shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Create a provider container with overrides
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
      environmentConfigProvider.overrideWith((ref) => env),
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
