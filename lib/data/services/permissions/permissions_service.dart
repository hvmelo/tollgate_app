import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

/// Service for handling permissions in the app
class PermissionsService {
  static final PermissionsService _instance = PermissionsService._internal();

  factory PermissionsService() {
    return _instance;
  }

  PermissionsService._internal();

  /// Request the necessary permissions for WiFi scanning and connection
  Future<bool> requestWiFiScanPermissions() async {
    List<Permission> permissionsToRequest = [
      Permission.location,
      Permission.locationWhenInUse,
    ];

    // // Add Android-specific permissions
    // if (Platform.isAndroid) {
    //   try {
    //     final nearbyWifiStatus = await Permission.nearbyWifiDevices.status;
    //     if (nearbyWifiStatus != PermissionStatus.restricted &&
    //         nearbyWifiStatus != PermissionStatus.permanentlyDenied) {
    //       permissionsToRequest.add(Permission.nearbyWifiDevices);
    //     }
    //   } catch (e) {
    //     debugPrint('Error checking NEARBY_WIFI_DEVICES permission: $e');
    //   }
    // }

    Map<Permission, PermissionStatus> statuses =
        await permissionsToRequest.request();

    // All permissions are granted
    return statuses.values.every((status) => status.isGranted);
  }

  /// Check if all necessary permissions for WiFi scanning and connection are granted
  Future<bool> hasWiFiScanPermissions() async {
    final hasLocationPermission = await Permission.location.isGranted;
    final hasLocationWhenInUsePermission =
        await Permission.locationWhenInUse.isGranted;

    if (!Platform.isAndroid) {
      // iOS only needs location permissions
      return hasLocationPermission && hasLocationWhenInUsePermission;
    }

    // For Android, check if we need NEARBY_WIFI_DEVICES permission (Android 13+)
    try {
      // final nearbyWifiStatus = await Permission.nearbyWifiDevices.status;
      // if (nearbyWifiStatus == PermissionStatus.restricted ||
      //     nearbyWifiStatus == PermissionStatus.permanentlyDenied) {
      //   // Permission doesn't exist on this Android version or was permanently denied
      //   return hasLocationPermission && hasLocationWhenInUsePermission;
      // }

      return hasLocationPermission && hasLocationWhenInUsePermission;
    } catch (e) {
      // If there's any error checking NEARBY_WIFI_DEVICES, fall back to location permissions
      debugPrint('Error checking NEARBY_WIFI_DEVICES permission: $e');
      return hasLocationPermission && hasLocationWhenInUsePermission;
    }
  }

  /// Open app settings so the user can enable permissions
  void openSettings() {
    openAppSettings();
  }
}
