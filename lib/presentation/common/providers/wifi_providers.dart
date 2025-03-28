import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/providers/service_providers.dart';
import '../../../core/result/result.dart';
import '../../../core/result/unit.dart';
import '../../../domain/errors/wifi_errors.dart';
import '../../../domain/models/wifi/wifi_network.dart';
import 'current_connection_provider.dart';

part 'wifi_providers.g.dart';

@riverpod
Future<Result<Unit, WifiConnectionError>> connectToNetwork(
  Ref ref,
  WiFiNetwork network,
) async {
  final wifiService = ref.read(wifiServiceProvider);
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
  final wifiService = ref.read(wifiServiceProvider);
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

/// Provider that handles WiFi network scanning and updates every 10 seconds
@riverpod
Stream<Result<List<WiFiNetwork>, WifiScanError>> wifiNetworksStream(
    Ref ref) async* {
  final wifiService = ref.watch(wifiServiceProvider);

  while (true) {
    final result = await wifiService.scanNetworks();
    yield result.fold(
      (networks) {
        // Sort networks by signal strength (strongest first)
        networks.sort((a, b) => b.signalStrength.compareTo(a.signalStrength));
        return Success(networks);
      },
      (error) {
        return Failure(error);
      },
    );

    await Future.delayed(const Duration(seconds: 10));
  }
}
