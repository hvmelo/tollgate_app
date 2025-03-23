import 'dart:async';
import 'dart:math';

import '../../../core/utils/result.dart';
import '../../../core/utils/unit.dart';
import '../../../domain/errors/wifi_errors.dart';
import '../../../domain/models/toll_gate_response.dart';
import '../../../domain/models/wifi_network.dart';
import '../wifi/wifi_service.dart';

/// Mock implementation of the WifiService for development environments
class MockWifiService implements WifiService {
  final Random _random = Random();
  String? _connectedSsid;

  @override
  Future<Result<String, WifiGetCurrentConnectionError>>
      getCurrentConnection() async {
    // Simulate checking the current connection
    await Future.delayed(const Duration(milliseconds: 500));
    return _connectedSsid != null
        ? Success(_connectedSsid!)
        : Failure(WifiGetCurrentConnectionError.failedToGetCurrentConnection(
            "No active connection"));
  }

  @override
  Future<Result<List<WiFiNetwork>, WifiScanError>> scanNetworks() async {
    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate random failure (5% chance)
    if (_random.nextInt(20) == 0) {
      return Failure(const WifiScanError.scanFailed(
          'Failed to scan networks. Please try again.'));
    }

    // Generate some random networks
    final networks = <WiFiNetwork>[];

    // TollGate networks
    for (int i = 0; i < 3; i++) {
      networks.add(
        WiFiNetwork(
          ssid: 'TollGate_${i + 1}',
          bssid: '00:11:22:33:44:${55 + i}',
          signalStrength:
              -(_random.nextInt(31) + 10), // Random number between -40 and -10
          frequency: 2400 + _random.nextInt(100),
          securityType: 'Open',
          isTollGate: true,
          satsPerMin: 5 + _random.nextInt(26),
        ),
      );
    }

    // Regular networks
    for (int i = 0; i < 8; i++) {
      networks.add(
        WiFiNetwork(
          ssid: 'WiFi_${i + 1}',
          bssid: '11:22:33:44:55:${i + 1}',
          signalStrength:
              -(_random.nextInt(66) + 25), // Random number between -90 and -25
          frequency: 2400 + _random.nextInt(100),
          securityType: _getRandomSecurityType(),
          isTollGate: false,
        ),
      );
    }

    return Success(networks);
  }

  String _getRandomSecurityType() {
    final types = ['Open', 'WEP', 'WPA', 'WPA2', 'WPA3'];
    return types[_random.nextInt(types.length)];
  }

  @override
  Future<Result<Unit, WifiConnectionError>> connectToNetwork(String ssid,
      [String? password]) async {
    // Simulate connection process
    await Future.delayed(const Duration(seconds: 1));

    // Simulate random connection failure (10% chance)
    if (_random.nextInt(10) == 0) {
      return Failure(WifiConnectionError.connectionFailed(
          'Failed to connect to $ssid. The network may not be in range or requires a password.'));
    }

    _connectedSsid = ssid;
    return const Success(unit);
  }

  @override
  bool checkIfTollGateNetwork(String ssid) {
    return ssid.contains('TollGate');
  }

  @override
  Future<Result<TollGateResponse, TollGateInfoResponseError>> getTollGateInfo(
      String ssid) async {
    // Simulate network info retrieval
    await Future.delayed(const Duration(seconds: 1));

    final response = TollGateResponse(
      providerName: 'TollGate Development',
      satsPerMin: 5 + _random.nextInt(25),
      initialCost: 1 + _random.nextInt(10),
      description: 'Development TollGate Network',
      mintUrl: 'https://test-mint.tollgate.network',
      paymentUrl: 'https://test-pay.tollgate.network',
      networkId: 'dev_${_random.nextInt(1000)}',
      ssid: ssid,
    );

    return Success(response);
  }

  @override
  Future<Result<Unit, TollGatePaymentError>> processPayment(
      TollGateResponse response) async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 1));

    // Simulate random payment failure (5% chance)
    if (_random.nextInt(20) == 0) {
      return Failure(const TollGatePaymentError.paymentFailed(
          'Payment processing failed'));
    }

    return const Success(unit);
  }

  @override
  Future<Result<Unit, WiFiDisconnectionError>> disconnectFromNetwork() async {
    // Simulate disconnection
    await Future.delayed(const Duration(milliseconds: 300));
    _connectedSsid = null;
    return const Success(unit);
  }

  @override
  String _getSecurityType(String capabilities) {
    final String caps = capabilities.toUpperCase();
    if (caps.contains('WPA3')) return 'WPA3';
    if (caps.contains('WPA2')) return 'WPA2';
    if (caps.contains('WPA')) return 'WPA';
    if (caps.contains('WEP')) return 'WEP';
    return 'Open';
  }
}
