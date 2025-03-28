import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/services/mocks/mock_tollgate_service.dart';
import '../../data/services/mocks/mock_wifi_service.dart';
import '../../data/services/tollgate/tollgate_service.dart';
import '../../data/services/wifi/wifi_service.dart';
import '../environment/environment_provider.dart';

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
