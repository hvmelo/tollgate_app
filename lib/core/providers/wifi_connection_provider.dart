import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/toll_gate_response.dart';
import '../../data/services/wifi_service.dart';

part 'wifi_connection_provider.g.dart';

/// Wi-Fi connection state
class WifiConnectionState {
  final bool isConnected;
  final String? connectedSsid;
  final bool isLoading;
  final String? error;
  final TollGateResponse? tollGateResponse;

  WifiConnectionState({
    this.isConnected = false,
    this.connectedSsid,
    this.isLoading = false,
    this.error,
    this.tollGateResponse,
  });

  WifiConnectionState copyWith({
    bool? isConnected,
    String? connectedSsid,
    bool? isLoading,
    String? error,
    TollGateResponse? tollGateResponse,
  }) {
    return WifiConnectionState(
      isConnected: isConnected ?? this.isConnected,
      connectedSsid: connectedSsid ?? this.connectedSsid,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      tollGateResponse: tollGateResponse ?? this.tollGateResponse,
    );
  }
}

@Riverpod(keepAlive: true)
class WifiConnection extends _$WifiConnection {
  final WifiService _wifiService = WifiService();

  @override
  WifiConnectionState build() {
    _initialize();
    return WifiConnectionState();
  }

  Future<void> _initialize() async {
    try {
      final currentConnection = await _wifiService.getCurrentConnection();

      if (currentConnection != null) {
        state = state.copyWith(
          isConnected: true,
          connectedSsid: currentConnection,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to get current connection: $e');
    }
  }

  Future<void> connectToNetwork({
    required String ssid,
    String? password,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      tollGateResponse: null,
    );

    try {
      // Connect to the network
      await _wifiService.connectToNetwork(ssid, password);

      // Check if this is a TollGate network
      final isTollGate = await _wifiService.checkIfTollGateNetwork(ssid);

      if (isTollGate) {
        // Get TollGate information
        final tollGateResponse = await _wifiService.getTollGateInfo(ssid);

        state = state.copyWith(
          isConnected: true,
          connectedSsid: ssid,
          isLoading: false,
          tollGateResponse: tollGateResponse,
        );
      } else {
        state = state.copyWith(
          isConnected: true,
          connectedSsid: ssid,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to connect: $e');
    }
  }

  Future<bool> connectWithPayment(TollGateResponse response) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Process the payment with the TollGate network
      await _wifiService.processPayment(response);

      state = state.copyWith(
        isConnected: true,
        connectedSsid: response.ssid,
        isLoading: false,
        tollGateResponse: response,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to connect with payment: $e',
      );
      return false;
    }
  }

  Future<void> disconnectFromNetwork() async {
    if (!state.isConnected) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _wifiService.disconnectFromNetwork();

      state = state.copyWith(
        isConnected: false,
        connectedSsid: null,
        isLoading: false,
        tollGateResponse: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to disconnect: $e',
      );
    }
  }
}
