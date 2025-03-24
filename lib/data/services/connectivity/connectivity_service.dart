import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _internetStatusController =
      StreamController<bool>.broadcast();
  Timer? _pollingTimer;
  bool _lastStatus = false;

  Stream<bool> get internetStatus => _internetStatusController.stream;

  ConnectivityService() {
    // Start monitoring connectivity changes
    _connectivity.onConnectivityChanged.listen(_checkInternetAccess);
    // Initial check
    _checkInternetAccess(null);
  }

  void dispose() {
    _pollingTimer?.cancel();
    _internetStatusController.close();
  }

  Future<void> _checkInternetAccess(
      ConnectivityResult? connectivityResult) async {
    if (connectivityResult == ConnectivityResult.none) {
      _updateStatus(false);
      return;
    }

    try {
      // Try to access a reliable endpoint
      final response = await http.get(Uri.parse('https://8.8.8.8')).timeout(
            const Duration(seconds: 5),
          );
      _updateStatus(response.statusCode == 200);
    } on TimeoutException catch (_) {
      _updateStatus(false);
    } on SocketException catch (_) {
      _updateStatus(false);
    } catch (e) {
      debugPrint('Error checking internet access: $e');
      _updateStatus(false);
    }
  }

  void _updateStatus(bool hasInternet) {
    if (_lastStatus != hasInternet) {
      _lastStatus = hasInternet;
      _internetStatusController.add(hasInternet);
    }
  }

  /// Check current internet connectivity
  Future<bool> checkInternetAccess() async {
    return _lastStatus;
  }
}
