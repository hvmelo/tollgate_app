import 'dart:async';
import 'dart:math';

import '../../domain/models/toll_gate_response.dart';
import '../../domain/models/wifi_network.dart';

/// Service to interact with Wi-Fi networks
class WifiService {
  final Random _random = Random();

  /// Get the current Wi-Fi connection
  Future<String?> getCurrentConnection() async {
    // Simulate checking the current connection
    await Future.delayed(const Duration(milliseconds: 500));

    // Return null to indicate not connected
    return null;
  }

  /// Scan for available Wi-Fi networks
  Future<List<WiFiNetwork>> scanNetworks() async {
    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 2));

    // Generate some random networks
    final networks = <WiFiNetwork>[];

    // TollGate networks
    for (int i = 0; i < 2; i++) {
      networks.add(
        WiFiNetwork(
          ssid: 'TollGate_${i + 1}',
          bssid: '00:11:22:33:44:${55 + i}',
          signalStrength:
              -(_random.nextInt(31)), // Random number between -30 and 0
          frequency: 2400 + _random.nextInt(100),
          securityType: 'Open',
          isTollGate: true,
          satsPerMin: 5 + _random.nextInt(26),
        ),
      );
    }

    // Regular networks
    for (int i = 0; i < 5; i++) {
      networks.add(
        WiFiNetwork(
          ssid: 'WiFi_${i + 1}',
          bssid: '11:22:33:44:55:${i + 1}',
          signalStrength:
              -(_random.nextInt(66) + 30), // Random number between -30 and -95
          frequency: 2400 + _random.nextInt(100),
          securityType: _random.nextBool() ? 'WPA2' : 'WPA3',
          isTollGate: false,
        ),
      );
    }

    return networks;
  }

  /// Connect to a Wi-Fi network
  Future<void> connectToNetwork(String ssid, [String? password]) async {
    // Simulate connection process
    await Future.delayed(const Duration(seconds: 2));

    // Simulate random connection failure
    if (_random.nextInt(10) == 0) {
      throw Exception('Failed to connect to $ssid');
    }
  }

  /// Check if a network is a TollGate network
  Future<bool> checkIfTollGateNetwork(String ssid) async {
    // Simulate checking
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if the SSID contains 'TollGate'
    return ssid.contains('TollGate');
  }

  /// Get TollGate network information
  Future<TollGateResponse> getTollGateInfo(String ssid) async {
    // Simulate network info retrieval
    await Future.delayed(const Duration(seconds: 1));

    return TollGateResponse(
      providerName: 'TollGate Provider',
      satsPerMin: 5 + _random.nextInt(25),
      initialCost: 1 + _random.nextInt(10),
      description: 'Pay-as-you-go Wi-Fi access',
      mintUrl: 'https://mint.tollgate.network',
      paymentUrl: 'https://pay.tollgate.network',
      networkId: 'net_${_random.nextInt(1000)}',
      ssid: ssid,
    );
  }

  /// Process payment for TollGate network
  Future<void> processPayment(TollGateResponse response) async {
    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Simulate random payment failure
    if (_random.nextInt(10) == 0) {
      throw Exception('Payment processing failed');
    }
  }

  /// Disconnect from the current network
  Future<void> disconnectFromNetwork() async {
    // Simulate disconnection
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
