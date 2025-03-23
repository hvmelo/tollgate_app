import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/services/service_factory.dart';
import '../../domain/errors/wifi_errors.dart';
import '../../domain/models/wifi_network.dart';
import '../utils/result.dart';

part 'wifi_scan_provider.g.dart';

/// Provider that handles WiFi network scanning
@riverpod
Future<Result<List<WiFiNetwork>, WifiScanError>> scanWifiNetworks(
    Ref ref) async {
  final wifiService = ServiceFactory().getWifiService();
  final result = await wifiService.scanNetworks();

  return result.fold(
    (error) => Failure(error),
    (networks) {
      // Sort networks by signal strength (strongest first)
      networks.sort((a, b) => b.signalStrength.compareTo(a.signalStrength));
      return Success(networks);
    },
  );
}

/// Provider for TollGate networks only
@riverpod
Future<Result<List<WiFiNetwork>, WifiScanError>> tollGateNetworks(
    Ref ref) async {
  final networks = await ref.watch(scanWifiNetworksProvider.future);
  return networks.fold(
    (error) => Failure(error),
    (networks) =>
        Success(networks.where((network) => network.isTollGate).toList()),
  );
}

/// Provider for regular (non-TollGate) networks
@riverpod
Future<Result<List<WiFiNetwork>, WifiScanError>> regularNetworks(
    Ref ref) async {
  final networks = await ref.watch(scanWifiNetworksProvider.future);
  return networks.fold(
    (error) => Failure(error),
    (networks) =>
        Success(networks.where((network) => !network.isTollGate).toList()),
  );
}
