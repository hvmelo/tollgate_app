import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tollgate_app/config/app_config.dart';

import 'core/providers/core_providers.dart';
import 'utils/provider_logger.dart';

/// Development config entry point.
/// Launch with `flutter run --target lib/main_development.dart`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration for development mode
  AppConfig.init(environment: AppEnvironment.development, useMocks: true);

  // Initialize the shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Create a provider container with overrides
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWith((ref) => sharedPreferences),
      // Use mock implementations in development mode
      // if (AppConfig.useMocks) ...[
      //   // Override the repository providers with mock implementations
      //   multiMintWalletRepositoryProvider.overrideWith(
      //     (ref) => FakeMultiMintWalletRepositoryImpl(),
      //   ),
      //   mintRepositoryProvider.overrideWith(
      //     (ref) => FakeMintRepositoryImpl(),
      //   ),
      //   mintTransactionsRepositoryProvider.overrideWith(
      //     (ref) => FakeMintTransactionsRepositoryImpl(),
      //   ),
      // ],
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
