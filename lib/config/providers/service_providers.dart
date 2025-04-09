import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/local/cashu_local_preferences.dart';
import '../../data/mocks/mock_tollgate_service.dart';
import '../../data/mocks/mock_wifi_service.dart';
import '../../data/services/tollgate/tollgate_service.dart';
import '../../data/services/wifi/wifi_service.dart';
import '../environment/environment_provider.dart';
import '../storage/local_storage_service_provider.dart';

part 'service_providers.g.dart';

@riverpod
WifiService wifiService(Ref ref) {
  final env = ref.watch(environmentConfigProvider);
  return env.useMocks ? MockWifiService() : WifiService();
}

@riverpod
TollgateService tollgateService(Ref ref) {
  final env = ref.watch(environmentConfigProvider);
  return env.useMocks ? MockTollgateService() : TollgateService();
}

@Riverpod(keepAlive: true)
CashuLocalPreferences cashuLocalPreferences(Ref ref) {
  final storageService = ref.watch(localStorageServiceProvider);
  return CashuLocalPreferences(localPropertiesService: storageService);
}
