import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/local/local_storage_service.dart';
import 'shared_preferences_provider.dart';

part 'local_storage_service_provider.g.dart';

@Riverpod(keepAlive: true)
LocalStorageService localStorageService(Ref ref) {
  final sharedPreferences = ref.read(sharedPreferencesProvider);
  return LocalStorageService(sharedPreferences);
}
