import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../config/providers/service_providers.dart';
import '../../../../core/result/result.dart';
import '../../../../domain/wifi/errors/wifi_errors.dart';
import '../../../../domain/wifi/models/wifi_network.dart';

part 'scan_networks_stream_provider.g.dart';

/// Provider that handles WiFi network scanning and updates every 10 seconds
@riverpod
Stream<Result<List<WiFiNetwork>, WifiScanError>> scanNetworksStream(
    Ref ref) async* {
  final wifiService = ref.watch(wifiServiceProvider);

  while (true) {
    final result = await wifiService.scanNetworks();
    yield result.fold(
      onSuccess: (networks) {
        // Sort networks by signal strength (strongest first)
        networks.sort((a, b) => b.signalStrength.compareTo(a.signalStrength));
        return Result.ok(networks);
      },
      onFailure: (error) {
        return Result.failure(error);
      },
    );

    await Future.delayed(const Duration(seconds: 10));
  }
}
