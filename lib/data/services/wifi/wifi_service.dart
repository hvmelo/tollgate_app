import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:tollgate_app/core/utils/unit.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

import '../../../core/utils/result.dart';
import '../../../domain/errors/wifi_errors.dart';
import '../../../domain/models/toll_gate_response.dart';
import '../../../domain/models/wifi_network.dart';
import '../permissions/permissions_service.dart';

/// Service to interact with Wi-Fi networks
class WifiService {
  final PermissionsService _permissionsService = PermissionsService();
  final Random _random = Random();
  final NetworkInfo _networkInfo = NetworkInfo();

  /// Get the current Wi-Fi connection
  Future<Result<String?, WifiGetCurrentConnectionError>>
      getCurrentConnection() async {
    try {
      // Check if we have the necessary permissions
      final hasPermissions = await _permissionsService.hasWiFiScanPermissions();
      if (!hasPermissions) {
        final granted = await _permissionsService.requestWiFiScanPermissions();
        if (!granted) {
          return Failure(
              const WifiGetCurrentConnectionError.permissionDenied());
        }
      }

      // Get the SSID of the currently connected WiFi network
      final wifiName = await _networkInfo.getWifiName();

      // The SSID usually comes with quotes, so remove them if present
      if (wifiName != null) {
        return Success(wifiName.replaceAll('"', ''));
      }

      return const Success(null);
    } catch (e) {
      debugPrint('Error getting current connection: $e');
      return Failure(
          const WifiGetCurrentConnectionError.failedToGetCurrentConnection(
              "Failed to get current WiFi connection"));
    }
  }

  /// Scan for available Wi-Fi networks
  Future<Result<List<WiFiNetwork>, WifiScanError>> scanNetworks() async {
    try {
      // Check if we have the necessary permissions
      final hasPermissions = await _permissionsService.hasWiFiScanPermissions();
      if (!hasPermissions) {
        final granted = await _permissionsService.requestWiFiScanPermissions();
        if (!granted) {
          // If permissions not granted, return a failure with explanation
          return Failure(const WifiScanError.permissionDenied());
        }
      }

      // Check if we can scan
      final canStartScan = await WiFiScan.instance.canStartScan();
      if (canStartScan != CanStartScan.yes) {
        return Failure(_getErrorFromCanStartScan(canStartScan));
      }

      // Start the scan
      await WiFiScan.instance.startScan();

      // Wait a bit for results to be available
      await Future.delayed(const Duration(seconds: 2));

      // Check if we can get the results
      final canGetResults = await WiFiScan.instance.canGetScannedResults();
      if (canGetResults != CanGetScannedResults.yes) {
        return Failure(_getErrorFromCanGetScannedResults(canGetResults));
      }

      // Get the scanned results
      final accessPoints = await WiFiScan.instance.getScannedResults();

      // Convert to our WiFiNetwork model
      final networks = <WiFiNetwork>[];

      for (final ap in accessPoints) {
        // Check if this is a TollGate network (based on SSID for demo)
        final isTollGate = ap.ssid.contains('TollGate') ||
            ap.ssid.toLowerCase().contains('tollgate');

        networks.add(
          WiFiNetwork(
            ssid: ap.ssid,
            bssid: ap.bssid,
            signalStrength: ap.level,
            frequency: ap.frequency,
            securityType: _getSecurityType(ap.capabilities),
            isTollGate: isTollGate,
            // Only add price for TollGate networks
            satsPerMin: isTollGate ? (5 + _random.nextInt(26)) : null,
          ),
        );
      }

      return Success(networks);
    } catch (e) {
      debugPrint('Error scanning networks: $e');
      // Return a failure with the error message
      return Failure(
          const WifiScanError.scanFailed("Failed to scan WiFi networks"));
    }
  }

  /// Helper method to convert CanStartScan to appropriate error
  WifiScanError _getErrorFromCanStartScan(CanStartScan status) {
    switch (status) {
      case CanStartScan.notSupported:
        return const WifiScanError.scanUnsupported();
      case CanStartScan.noLocationPermissionRequired:
      case CanStartScan.noLocationPermissionDenied:
      case CanStartScan.noLocationPermissionUpgradeAccuracy:
        return const WifiScanError.permissionDenied();
      case CanStartScan.noLocationServiceDisabled:
        return const WifiScanError.locationServiceDisabled();
      case CanStartScan.failed:
        return const WifiScanError.scanFailed("Failed to trigger WiFi scan");
      default:
        return const WifiScanError.scanFailed("Unknown scan error");
    }
  }

  /// Helper method to convert CanGetScannedResults to appropriate error
  WifiScanError _getErrorFromCanGetScannedResults(CanGetScannedResults status) {
    switch (status) {
      case CanGetScannedResults.notSupported:
        return const WifiScanError.scanUnsupported();
      case CanGetScannedResults.noLocationPermissionRequired:
      case CanGetScannedResults.noLocationPermissionDenied:
      case CanGetScannedResults.noLocationPermissionUpgradeAccuracy:
        return const WifiScanError.permissionDenied();
      case CanGetScannedResults.noLocationServiceDisabled:
        return const WifiScanError.locationServiceDisabled();
      default:
        return const WifiScanError.scanFailed(
            "Unknown error retrieving scan results");
    }
  }

  /// Determine security type from capabilities string
  String _getSecurityType(String capabilities) {
    final String caps = capabilities.toUpperCase();
    if (caps.contains('WPA3')) return 'WPA3';
    if (caps.contains('WPA2')) return 'WPA2';
    if (caps.contains('WPA')) return 'WPA';
    if (caps.contains('WEP')) return 'WEP';
    return 'Open';
  }

  /// Connect to a Wi-Fi network
  Future<Result<Unit, WifiConnectionError>> connectToNetwork(String ssid,
      [String? password]) async {
    try {
      // Check if we have the necessary permissions
      final hasPermissions = await _permissionsService.hasWiFiScanPermissions();
      if (!hasPermissions) {
        final granted = await _permissionsService.requestWiFiScanPermissions();
        if (!granted) {
          return Failure(const WifiConnectionError.permissionDenied());
        }
      }

      // Only Android and iOS are supported by wifi_iot
      if (Platform.isAndroid) {
        // For Android, we can use the wifi_iot package
        if (password != null) {
          // Connect with password
          final result = await WiFiForIoTPlugin.connect(
            ssid,
            password: password,
            security: NetworkSecurity.WPA, // Adjust security type as needed
          );

          if (!result) {
            return Failure(WifiConnectionError.connectionFailed(
              'Failed to connect to $ssid. Please check the password and try again.',
            ));
          }
        } else {
          // Connect to open network
          final result = await WiFiForIoTPlugin.connect(
            ssid,
            security: NetworkSecurity.NONE,
          );

          if (!result) {
            return Failure(WifiConnectionError.connectionFailed(
              'Failed to connect to $ssid. The network may not be in range or requires a password.',
            ));
          }
        }

        return const Success(unit);
      } else {
        // iOS doesn't allow programmatic WiFi connection
        return Failure(const WifiConnectionError.platformNotSupported());
      }
    } catch (e) {
      debugPrint('Error connecting to network: $e');
      return Failure(WifiConnectionError.connectionFailed(
          'Failed to connect to $ssid: ${e.toString()}'));
    }
  }

  /// Check if a network is a TollGate network
  bool checkIfTollGateNetwork(String ssid) {
    final isTollGate =
        ssid.contains('TollGate') || ssid.toLowerCase().contains('tollgate');
    return isTollGate;
  }

  /// Get information about a TollGate network
  Future<Result<TollGateResponse, TollGateInfoResponseError>> getTollGateInfo(
      String ssid) async {
    try {
      // This would be implemented to communicate with the TollGate server
      // For now, we'll create a mock response
      await Future.delayed(const Duration(seconds: 1));

      final tollGateResponse = TollGateResponse(
        providerName: 'TollGate Network',
        satsPerMin: 10,
        initialCost: 5,
        description: 'Pay-per-use WiFi network',
        mintUrl: 'https://mint.tollgate.network',
        paymentUrl: 'https://pay.tollgate.network',
        networkId: 'tg_${_random.nextInt(1000)}',
        ssid: ssid,
      );

      return Success(tollGateResponse);
    } catch (e) {
      debugPrint('Error getting TollGate information: $e');
      return Failure(TollGateInfoResponseError.responseFailed(
          'Failed to get information for $ssid'));
    }
  }

  /// Process payment for a TollGate network
  Future<Result<Unit, TollGatePaymentError>> processPayment(
      TollGateResponse response) async {
    try {
      // This would implement actual payment processing with the TollGate server
      // For now, just simulate the process
      await Future.delayed(const Duration(seconds: 1));

      // Simulate random failure (5% chance)
      if (_random.nextInt(20) == 0) {
        return Failure(const TollGatePaymentError.paymentFailed(
          'Payment processing failed. Please try again.',
        ));
      }

      return const Success(unit);
    } catch (e) {
      debugPrint('Error processing payment: $e');
      return Failure(
          TollGatePaymentError.paymentFailed('Failed to process payment'));
    }
  }

  /// Disconnect from the current network
  Future<Result<Unit, WiFiDisconnectionError>> disconnectFromNetwork() async {
    try {
      if (Platform.isAndroid) {
        // For Android, use the wifi_iot package
        final result = await WiFiForIoTPlugin.disconnect();

        if (!result) {
          return Failure(const WiFiDisconnectionError.disconnectionFailed(
            'Failed to disconnect from network',
          ));
        }
      } else {
        // For other platforms, just simulate
        await Future.delayed(const Duration(milliseconds: 500));
      }

      return const Success(unit);
    } catch (e) {
      debugPrint('Error disconnecting from network: $e');
      return Failure(WiFiDisconnectionError.disconnectionFailed(
          'Failed to disconnect from network'));
    }
  }
}
