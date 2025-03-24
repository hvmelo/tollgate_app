import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/result.dart';
import '../../../core/utils/unit.dart';
import '../../../data/services/wifi/wifi_service.dart';
import '../../../domain/errors/wifi_errors.dart';
import '../../../domain/models/wifi_network.dart';
import 'current_connection_provider.dart';

part 'wifi_providers.g.dart';

@Riverpod(keepAlive: true)
WifiService wifiService(Ref ref) {
  return WifiService();
}

@riverpod
Future<Result<Unit, WifiConnectionError>> connectToNetwork(
  Ref ref,
  WiFiNetwork network,
) async {
  final wifiService = ref.watch(wifiServiceProvider);
  final result = await wifiService.connectToNetwork(network);
  return result.fold(
    (success) {
      ref.invalidate(currentConnectionProvider);
      return Success(unit);
    },
    (failure) => Failure(failure),
  );
}

@riverpod
Future<Result<Unit, WifiRegistrationError>> registerNetwork(
  Ref ref,
  WiFiNetwork network, {
  String? password,
}) async {
  final wifiService = ref.watch(wifiServiceProvider);
  final result = await wifiService.registerNetwork(
    ssid: network.ssid,
    bssid: network.bssid,
    password: password,
  );
  return result.fold(
    (success) {
      ref.invalidate(currentConnectionProvider);
      return Success(unit);
    },
    (failure) => Failure(failure),
  );
}
