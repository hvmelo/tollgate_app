import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tollgate_app/config/environment/environment_provider.dart';

import 'config/environment/environment_config.dart';
import 'config/providers/repository_providers.dart';
import 'config/providers/service_providers.dart';
import 'config/storage/shared_preferences_provider.dart';
import 'domain/wallet/value_objects/mint_url.dart';
import 'main.dart';
import 'config/logging/provider_logger.dart';

/// Staging config entry point.
/// Launch with `flutter run --target lib/main_staging.dart`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app configuration for staging mode with real implementations
  final env = EnvironmentConfig.staging();

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

  // Let's add a initial mint to the wallet
  final walletRepo = await container.read(walletRepositoryProvider.future);
  await walletRepo.addMint(MintUrl.fromData('https://testnut.cashu.space'));

  // Let's add the current mint
  final cashuLocalPreferences = container.read(cashuLocalPreferencesProvider);
  cashuLocalPreferences.saveCurrentMintUrl(
    'https://testnut.cashu.space',
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MainApp(),
    ),
  );
}
