import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:wifi_iot/wifi_iot.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../models/connection_state.dart';
import '../models/wifi_network.dart';

/// Service for connecting to Wi-Fi networks and verifying TollGate status
class WiFiConnectionService {
  final NetworkInfo _networkInfo = NetworkInfo();

  /// Connect to a specific Wi-Fi network
  Future<ConnectionState> connectToNetwork(WiFiNetwork network) async {
    try {
      // Create a connecting state
      final connectingState = ConnectionState(
        status: ConnectionStatus.connecting,
        ssid: network.ssid,
        bssid: network.bssid,
        isTollGate: network.isTollGate,
      );

      // iOS doesn't support direct Wi-Fi connection through API
      if (Platform.isIOS) {
        // On iOS, we can only use NEHotspotConfiguration which will prompt the user
        // For simplicity, we'll suggest the user connect manually
        return connectingState.copyWith(
          status: ConnectionStatus.failed,
          error: 'On iOS, please connect to the network manually in Settings.',
        );
      }

      // Connect to the network on Android
      bool success;

      // Determine security type and if password is needed
      if (network.securityType.toUpperCase() == 'OPEN') {
        // Connect to open network
        success = await WiFiForIoTPlugin.connect(
          network.ssid,
          withInternet: true, // Important to keep connection open
        );
      } else {
        // For secured networks, we'd need a password
        // For TollGate networks, we might have a predefined password
        final password = _getTollGatePassword(network);

        success = await WiFiForIoTPlugin.connect(
          network.ssid,
          password: password,
          withInternet: true,
        );
      }

      if (!success) {
        return connectingState.copyWith(
          status: ConnectionStatus.failed,
          error: 'Failed to connect to network',
        );
      }

      // Force traffic over Wi-Fi even if it has no internet
      // This is important for TollGate networks before payment
      if (network.isTollGate) {
        await WiFiForIoTPlugin.forceWifiUsage(true);
      }

      // Get the connection details
      final connectedState = await _getConnectionDetails(
        connectingState.copyWith(status: ConnectionStatus.connected),
      );

      // If it's a TollGate network, verify it
      if (network.isTollGate) {
        return await verifyTollGateNetwork(connectedState);
      }

      return connectedState;
    } catch (e) {
      return ConnectionState(
        status: ConnectionStatus.failed,
        ssid: network.ssid,
        error: 'Error connecting to network: $e',
      );
    }
  }

  /// Get the current connection details
  Future<ConnectionState> _getConnectionDetails(ConnectionState state) async {
    try {
      // Get current SSID
      final ssid = await WiFiForIoTPlugin.getSSID() ?? state.ssid;

      // Get current BSSID
      final bssid = await WiFiForIoTPlugin.getBSSID() ?? state.bssid;

      // Get gateway IP
      final gatewayIP = await _networkInfo.getWifiGatewayIP() ?? '';

      return state.copyWith(ssid: ssid, bssid: bssid, routerIp: gatewayIP);
    } catch (e) {
      // If we can't get details, return the original state
      return state;
    }
  }

  /// Verify if the connected network is a TollGate network
  Future<ConnectionState> verifyTollGateNetwork(ConnectionState state) async {
    if (state.routerIp == null || state.routerIp!.isEmpty) {
      return state.copyWith(
        status: ConnectionStatus.failed,
        error: 'Cannot determine router IP for verification',
      );
    }

    try {
      // Set state to verifying
      final verifyingState = state.copyWith(status: ConnectionStatus.verifying);

      // URL for TollGate verification (port 2121)
      final url = 'http://${state.routerIp}:2121/status';

      // Set a short timeout for verification
      final response = await http
          .get(Uri.parse(url))
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => http.Response('{"error": "Timeout"}', 408),
          );

      if (response.statusCode != 200) {
        return verifyingState.copyWith(
          status: ConnectionStatus.failed,
          error:
              'Router verification failed with status ${response.statusCode}',
          isTollGate: false,
        );
      }

      // Parse the response
      final Map<String, dynamic> data = json.decode(response.body);
      final tollGateResponse = TollGateResponse.fromJson(data);

      if (!tollGateResponse.isTollGate) {
        return verifyingState.copyWith(
          status: ConnectionStatus.failed,
          error: 'Not a TollGate network',
          isTollGate: false,
        );
      }

      // TollGate verified!
      return verifyingState.copyWith(
        status: ConnectionStatus.verified,
        price: tollGateResponse.price,
        priceUnit: tollGateResponse.priceUnit,
        timeLimit: tollGateResponse.timeLimit,
        dataLimit: tollGateResponse.dataLimit,
        isTollGate: true,
      );
    } catch (e) {
      return state.copyWith(
        status: ConnectionStatus.failed,
        error: 'Error verifying TollGate network: $e',
      );
    }
  }

  /// Send payment to the TollGate router
  Future<bool> sendPayment(ConnectionState state, List<String> tokens) async {
    if (!state.isVerifiedTollGate || state.routerIp == null) {
      return false;
    }

    try {
      // URL for TollGate payment
      final url = 'http://${state.routerIp}:2121/pay';

      // Create payment payload
      final payload = {'tokens': tokens};

      // Send the payment
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response('{"error": "Timeout"}', 408),
          );

      if (response.statusCode != 200) {
        return false;
      }

      // Parse the response
      final Map<String, dynamic> data = json.decode(response.body);

      // Check if payment was successful
      return data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Disconnect from the current network
  Future<bool> disconnect() async {
    if (Platform.isIOS) {
      // Can't disconnect programmatically on iOS
      return false;
    }

    try {
      // Disable forcing Wi-Fi usage
      await WiFiForIoTPlugin.forceWifiUsage(false);

      // Disconnect from the network
      return await WiFiForIoTPlugin.disconnect();
    } catch (e) {
      return false;
    }
  }

  /// Get a predefined password for TollGate networks if needed
  String _getTollGatePassword(WiFiNetwork network) {
    // In a real implementation, this could be a known password for TollGate networks
    // or could be obtained from configuration

    // For simplicity, we'll use a default password
    return 'tollgate123';
  }
}
