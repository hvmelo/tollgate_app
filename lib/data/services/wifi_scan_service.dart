import 'dart:async';
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

import '../../domain/models/wifi_network.dart';

/// Service for scanning Wi-Fi networks and identifying TollGate networks
class WiFiScanService {
  /// Check if scanning is supported on this device/platform
  Future<bool> isScanningSupported() async {
    if (!Platform.isAndroid) {
      // iOS doesn't support programmatic Wi-Fi scanning
      return false;
    }

    final result = await WiFiScan.instance.canStartScan();
    return result == CanStartScan.yes;
  }

  /// Request necessary permissions for Wi-Fi scanning
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) {
      // iOS doesn't need permissions for our limited functionality
      return true;
    }

    // For Android 13+, request nearby devices permission
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo();
      if (androidInfo.version.sdkInt >= 33) {
        // Android 13+
        final status = await Permission.nearbyWifiDevices.request();
        return status.isGranted;
      }
    }

    // For older Android versions, request location permission
    final locationStatus = await Permission.locationWhenInUse.request();
    return locationStatus.isGranted;
  }

  /// Start scanning for Wi-Fi networks
  Future<List<WiFiNetwork>> startScan() async {
    if (!Platform.isAndroid) {
      // On iOS, return a mock or empty list
      // since we can't programmatically scan
      return [];
    }

    // Check permissions
    final hasPermission = await requestPermissions();
    if (!hasPermission) {
      throw Exception('Permission denied for Wi-Fi scanning');
    }

    // Check if we can start scanning
    final canStartScan = await WiFiScan.instance.canStartScan();
    if (canStartScan != CanStartScan.yes) {
      throw Exception('Cannot start Wi-Fi scan: $canStartScan');
    }

    // Start the scan
    final result = await WiFiScan.instance.startScan();
    if (!result) {
      throw Exception('Failed to start scan');
    }

    // Get scan results
    final scanResults = await WiFiScan.instance.getScannedResults();

    // Convert to our WiFiNetwork model and identify TollGate networks
    final networks = <WiFiNetwork>[];

    for (final result in scanResults) {
      final bool isTollGate = _isTollGateNetwork(result);
      final network = WiFiNetwork.fromScanResult(
        result,
        isTollGate: isTollGate,
        price: isTollGate ? _extractPrice(result) : null,
        unit: isTollGate ? _extractPriceUnit(result) : null,
      );

      networks.add(network);
    }

    // Sort networks: TollGate first, then by signal strength
    networks.sort((a, b) {
      if (a.isTollGate && !b.isTollGate) return -1;
      if (!a.isTollGate && b.isTollGate) return 1;
      return b.signalStrength.compareTo(a.signalStrength);
    });

    return networks;
  }

  /// Determine if a network is a TollGate network from its beacon data
  bool _isTollGateNetwork(WiFiAccessPoint ap) {
    // In a real implementation, we would analyze IEs (Information Elements)
    // to look for a vendor-specific IE (ID 221) with TollGate identifier

    // For this implementation, we'll use a simplified approach:
    // Check if the SSID contains "TollGate" or has a specific pattern
    final ssid = ap.ssid ?? '';
    return ssid.toLowerCase().contains('tollgate') ||
        ssid.toLowerCase().contains('toll_gate') ||
        ssid.toLowerCase().contains('toll-gate');
  }

  /// Extract price information from beacon data
  double? _extractPrice(WiFiAccessPoint ap) {
    // In a real implementation, this would parse the vendor-specific IE
    // to extract the price value embedded in the beacon frame

    // For this simplified implementation:
    // Try to extract price from SSID if it follows patterns like:
    // "TollGate_5sats" or "TollGate_5"
    final ssid = ap.ssid ?? '';
    final parts = ssid.split('_');

    if (parts.length > 1) {
      final lastPart = parts.last.replaceAll(RegExp(r'[^0-9.]'), '');
      if (lastPart.isNotEmpty) {
        return double.tryParse(lastPart);
      }
    }

    // Default price if we can't extract it
    return 5.0;
  }

  /// Extract price unit from beacon data
  String? _extractPriceUnit(WiFiAccessPoint ap) {
    // In a real implementation, this would parse the vendor IE
    // to extract the price unit (sats, BTC, etc.)

    // For this simplified implementation:
    final ssid = ap.ssid ?? '';
    if (ssid.toLowerCase().contains('sat')) return 'sats';

    // Default unit
    return 'sats';
  }
}

// Placeholder for Android SDK version checking
// In a real app, you would implement this properly
class DeviceInfoPlugin {
  Future<AndroidInfo> androidInfo() async {
    return AndroidInfo();
  }
}

class AndroidInfo {
  AndroidVersion version = AndroidVersion();
}

class AndroidVersion {
  int sdkInt = 30; // Placeholder for SDK version
}
