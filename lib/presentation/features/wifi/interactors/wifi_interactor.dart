import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../config/providers/service_providers.dart';
import '../../../../core/result/result.dart';
import '../../../../core/result/unit.dart';
import '../../../../domain/wifi/errors/wifi_errors.dart';
import '../../../../domain/wifi/models/wifi_network.dart';
import '../providers/current_connection_state_stream_provider.dart';

class WifiNetworkInteractor {
  final Ref ref;

  WifiNetworkInteractor(this.ref);

  Future<Result<Unit, WifiConnectionError>> connectOrRegister(
      WiFiNetwork network,
      {String? password}) async {
    final service = ref.read(wifiServiceProvider);

    // final isRegisteredResult = await service.isNetworkRegistered(network);
    // if (isRegisteredResult.isError) {
    //   return Result.error(
    //       WifiConnectionError.registrationFailed("Check failed"));
    // }

    // final isRegistered = isRegisteredResult.value!;

    if (true) {
      final registrationResult = await service.registerNetwork(
        ssid: network.ssid,
        bssid: network.bssid,
        password: password,
      );
      if (registrationResult.isFailure) {
        return Result.failure(
            WifiConnectionError.registrationFailed("Failed to register"));
      }
      final couldRegister = registrationResult.value!;
      if (!couldRegister) {
        final result = await service.connectToNetwork(network, password);
        if (result.isFailure) {
          return Result.failure(
              WifiConnectionError.connectionFailed("Failed to connect"));
        }
      }
      ref.invalidate(currentConnectionStateStreamProvider);
    }

    return Result.ok(unit);
  }
}
