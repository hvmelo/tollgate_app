import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:tollgate_app/core/utils/unit.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

import '../../../core/utils/result.dart';
import '../../../domain/errors/wifi_errors.dart';
import '../../../domain/models/wifi_connection_info.dart';
import '../../../domain/models/wifi_network.dart';
import '../permissions/permissions_service.dart';

/// Service to interact with Wi-Fi networks
class WifiService {
  final PermissionsService _permissionsService = PermissionsService();
  final Random _random = Random();

  /// Gets information about the current WiFi connection
  Future<Result<WifiConnectionInfo?, WifiGetCurrentConnectionError>>
      getCurrentConnection() async {
    try {
      // Get connection info using network_info_plus
      final connectionInfo = await WifiConnectionInfo.fromNetworkInfo();

      if (!connectionInfo.isConnected) {
        return const Success(null); // Not connected to any network
      }

      return Success(connectionInfo);
    } catch (e) {
      debugPrint('Error getting current connection: $e');
      return Failure(
        WifiGetCurrentConnectionError.failedToGetCurrentConnection(
          e.toString(),
        ),
      );
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
  Future<Result<Unit, WifiConnectionError>> connectToNetwork(
      WiFiNetwork network,
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
            network.ssid,
            bssid: network.bssid,
            password: password,
            security: _networkSecurityForString(network.securityType),
            withInternet: true,
          );

          await WiFiForIoTPlugin.forceWifiUsage(true);

          if (!result) {
            return Failure(WifiConnectionError.connectionFailed(
              'Failed to connect to ${network.ssid}. Please check the password and try again.',
            ));
          }
        } else {
          // Connect to open network
          final result = await WiFiForIoTPlugin.connect(
            network.ssid,
            security: NetworkSecurity.NONE,
          );

          if (!result) {
            return Failure(WifiConnectionError.connectionFailed(
              'Failed to connect to ${network.ssid}. The network may not be in range or requires a password.',
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
          'Failed to connect to ${network.ssid}: ${e.toString()}'));
    }
  }

  Future<Result<Unit, WifiRegistrationError>> registerNetwork({
    required String ssid,
    String? bssid,
    String? password,
  }) async {
    try {
      final result = await WiFiForIoTPlugin.registerWifiNetwork(
        ssid,
        bssid: bssid,
        password: password,
      );
      if (!result) {
        return Failure(const WifiRegistrationError.registrationFailed(
          'Failed to register network',
        ));
      }
      return const Success(unit);
    } catch (e) {
      debugPrint('Error registering network: $e');
      return Failure(const WifiRegistrationError.registrationFailed(
          'Failed to register network'));
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

  NetworkSecurity _networkSecurityForString(String security) {
    switch (security.toLowerCase()) {
      case 'wpa':
      case 'wpa2':
      case 'wpa/wpa2':
        return NetworkSecurity.WPA;
      case 'wep':
        return NetworkSecurity.WEP;
      case 'none':
      case 'open':
        return NetworkSecurity.NONE;
      default:
        return NetworkSecurity.NONE;
    }
  }
}
