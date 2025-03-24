import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:async';

import '../../data/services/service_factory.dart';
import '../../domain/errors/wifi_errors.dart';
import '../../domain/models/wifi_network.dart';
import '../utils/result.dart';

part 'wifi_scan_provider.g.dart';

/// Provider that handles WiFi network scanning and updates every 10 seconds
@riverpod
Stream<Result<List<WiFiNetwork>, WifiScanError>> wifiNetworksStream(
    Ref ref) async* {
  final wifiService = ServiceFactory().getWifiService();

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
