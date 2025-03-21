import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/wifi_network.dart';
import '../../data/services/wifi_service.dart';

part 'wifi_scan_provider.g.dart';

// Wi-Fi scan state
class WiFiScanState {
  final List<WiFiNetwork> networks;
  final bool isLoading;
  final String? error;
  final bool isSupported;

  WiFiScanState({
    this.networks = const [],
    this.isLoading = false,
    this.error,
    this.isSupported = true,
  });

  // TollGate networks
  List<WiFiNetwork> get tollGateNetworks =>
      networks.where((network) => network.isTollGate).toList();

  // Regular networks
  List<WiFiNetwork> get regularNetworks =>
      networks.where((network) => !network.isTollGate).toList();

  WiFiScanState copyWith({
    List<WiFiNetwork>? networks,
    bool? isLoading,
    String? error,
    bool? isSupported,
  }) {
    return WiFiScanState(
      networks: networks ?? this.networks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSupported: isSupported ?? this.isSupported,
    );
  }
}

@Riverpod(keepAlive: true)
class WifiScan extends _$WifiScan {
  final WifiService _wifiService = WifiService();

  @override
  WiFiScanState build() {
    return WiFiScanState();
  }

  Future<void> startScan() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final networks = await _wifiService.scanNetworks();

      // Sort networks by signal strength (strongest first)
      networks.sort((a, b) => b.signalStrength.compareTo(a.signalStrength));

      state = state.copyWith(networks: networks, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to scan networks: $e',
      );
    }
  }

  void setSupported(bool isSupported) {
    state = state.copyWith(isSupported: isSupported);
  }
}
