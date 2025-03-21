import 'package:flutter/foundation.dart';

/// Represents a Wi-Fi network found during scanning
class WiFiNetwork {
  final String ssid;
  final String bssid;
  final int signalStrength;
  final int frequency;
  final String securityType;
  final bool isTollGate;
  final double? pricePerMb;
  final String? priceUnit;

  WiFiNetwork({
    required this.ssid,
    required this.bssid,
    required this.signalStrength,
    required this.frequency,
    required this.securityType,
    this.isTollGate = false,
    this.pricePerMb,
    this.priceUnit,
  });

  factory WiFiNetwork.fromJson(Map<String, dynamic> json) {
    return WiFiNetwork(
      ssid: json['ssid'] as String,
      bssid: json['bssid'] as String,
      signalStrength: json['signalStrength'] as int,
      frequency: json['frequency'] as int,
      securityType: json['securityType'] as String,
      isTollGate: json['isTollGate'] as bool? ?? false,
      pricePerMb:
          json['pricePerMb'] != null
              ? (json['pricePerMb'] as num).toDouble()
              : null,
      priceUnit: json['priceUnit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ssid': ssid,
      'bssid': bssid,
      'signalStrength': signalStrength,
      'frequency': frequency,
      'securityType': securityType,
      'isTollGate': isTollGate,
      'pricePerMb': pricePerMb,
      'priceUnit': priceUnit,
    };
  }

  /// Create a WiFiNetwork from a scan result
  factory WiFiNetwork.fromScanResult(
    dynamic scanResult, {
    bool isTollGate = false,
    double? price,
    String? unit,
  }) {
    // Platform-specific handling of scan results
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Extract data from Android scan result
      return WiFiNetwork(
        ssid: scanResult.ssid ?? 'Unknown SSID',
        bssid: scanResult.bssid ?? 'Unknown BSSID',
        signalStrength: scanResult.level ?? -100,
        frequency: scanResult.frequency ?? 0,
        securityType: _getSecurityType(scanResult),
        isTollGate: isTollGate,
        pricePerMb: price,
        priceUnit: unit,
      );
    } else {
      // iOS or unsupported platform
      return WiFiNetwork(
        ssid: scanResult.ssid ?? 'Unknown SSID',
        bssid: scanResult.bssid ?? 'Unknown BSSID',
        signalStrength: -70, // Default value for iOS
        frequency: 0, // Default value for iOS
        securityType: 'Unknown',
        isTollGate: isTollGate,
        pricePerMb: price,
        priceUnit: unit,
      );
    }
  }

  /// Determine security type from scan result
  static String _getSecurityType(dynamic scanResult) {
    // This would depend on the exact structure of the scan result from the plugin
    if (scanResult.capabilities == null) return 'Unknown';

    final String capabilities =
        scanResult.capabilities.toString().toUpperCase();
    if (capabilities.contains('WPA3')) return 'WPA3';
    if (capabilities.contains('WPA2')) return 'WPA2';
    if (capabilities.contains('WPA')) return 'WPA';
    if (capabilities.contains('WEP')) return 'WEP';
    return 'Open';
  }

  /// Create a copy of this WiFiNetwork with updated values
  WiFiNetwork copyWith({
    String? ssid,
    String? bssid,
    int? signalStrength,
    int? frequency,
    String? securityType,
    bool? isTollGate,
    double? pricePerMb,
    String? priceUnit,
  }) {
    return WiFiNetwork(
      ssid: ssid ?? this.ssid,
      bssid: bssid ?? this.bssid,
      signalStrength: signalStrength ?? this.signalStrength,
      frequency: frequency ?? this.frequency,
      securityType: securityType ?? this.securityType,
      isTollGate: isTollGate ?? this.isTollGate,
      pricePerMb: pricePerMb ?? this.pricePerMb,
      priceUnit: priceUnit ?? this.priceUnit,
    );
  }

  @override
  String toString() {
    return 'WiFiNetwork(ssid: $ssid, isTollGate: $isTollGate, price: ${pricePerMb ?? "N/A"} ${priceUnit ?? ""})';
  }
}
