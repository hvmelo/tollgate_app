import 'dart:async';
import 'dart:math';

import '../../../core/utils/result.dart';
import '../../../core/utils/unit.dart';
import '../../../domain/errors/wifi_errors.dart';
import '../../../domain/models/wifi_network.dart';
import '../../../domain/models/wifi_connection_info.dart';
import '../wifi/wifi_service.dart';

/// Mock implementation of the WifiService for development environments
class MockWifiService implements WifiService {
  final Random _random = Random();
  final bool _shouldSucceed;
  final Duration _delay;
  WiFiNetwork? _mockConnectedNetwork;

  MockWifiService({
    bool shouldSucceed = true,
    Duration delay = const Duration(milliseconds: 500),
  })  : _shouldSucceed = shouldSucceed,
        _delay = delay;

  @override
  Future<Result<WifiConnectionInfo?, WifiGetCurrentConnectionError>>
      getCurrentConnection() async {
    await Future.delayed(_delay);

    if (!_shouldSucceed) {
      return Failure(
        WifiGetCurrentConnectionError.failedToGetCurrentConnection(
            'Mock error'),
      );
    }

    if (_mockConnectedNetwork == null) {
      return const Success(null);
    }

    // Create a mock connection info
    return Success(WifiConnectionInfo(
      ssid: _mockConnectedNetwork!.ssid,
      bssid: '00:11:22:33:44:55', // Mock BSSID
      ipAddress: '192.168.1.100', // Mock IP
      subnet: '255.255.255.0', // Mock subnet
      gatewayIp: '192.168.1.1', // Mock gateway
      broadcast: '192.168.1.255', // Mock broadcast
    ));
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
  Future<Result<Unit, WifiConnectionError>> connectToNetwork(
      WiFiNetwork network,
      [String? password]) async {
    // Simulate connection process
    await Future.delayed(const Duration(seconds: 1));

    // Simulate random connection failure (10% chance)
    if (_random.nextInt(10) == 0) {
      return Failure(WifiConnectionError.connectionFailed(
          'Failed to connect to ${network.ssid}. The network may not be in range or requires a password.'));
    }

    return const Success(unit);
  }

  @override
  bool checkIfTollGateNetwork(String ssid) {
    return ssid.contains('TollGate');
  }

  @override
  Future<Result<Unit, WiFiDisconnectionError>> disconnectFromNetwork() async {
    // Simulate disconnection
    await Future.delayed(const Duration(milliseconds: 300));
    return const Success(unit);
  }

  @override
  Future<Result<Unit, WifiRegistrationError>> registerNetwork({
    required String ssid,
    String? bssid,
    String? password,
  }) async {
    await Future.delayed(_delay);
    _mockConnectedNetwork = WiFiNetwork(
      ssid: ssid,
      bssid: bssid ?? '00:11:22:33:44:55',
      signalStrength: -50,
      frequency: 2400,
      securityType: password != null ? 'WPA2' : 'Open',
      isTollGate: false,
    );
    return const Success(unit);
  }
}
