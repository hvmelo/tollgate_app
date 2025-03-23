import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/services/service_factory.dart';
import '../../data/services/wifi/wifi_service.dart';
import '../../domain/errors/wifi_errors.dart';
import '../../domain/models/toll_gate_response.dart';
import '../../core/utils/result.dart';
import '../../core/utils/unit.dart';

part 'wifi_connection_provider.g.dart';
part 'wifi_connection_provider.freezed.dart';

@freezed
class WifiConnectionState with _$WifiConnectionState {
  const factory WifiConnectionState({
    @Default(false) bool isConnected,
    String? connectedSsid,
    WifiGetCurrentConnectionError? error,
    @Default(false) bool isTollGate,
    TollGateResponse? tollGateResponse,
  }) = _WifiConnectionState;
}

/// Provider for connecting to a WiFi network
@riverpod
class WifiConnectionController extends _$WifiConnectionController {
  late final WifiService _wifiService;

  @override
  Future<WifiConnectionState> build() async {
    // Get the appropriate service implementation
    _wifiService = ServiceFactory().getWifiService();
    final result = await _wifiService.getCurrentConnection();
    return result.fold(
      (error) => WifiConnectionState(error: error),
      (ssid) async {
        if (ssid == null) {
          return WifiConnectionState(
            isConnected: false,
          );
        }
        final isTollGate = _wifiService.checkIfTollGateNetwork(ssid);
        if (isTollGate) {
          final tollGateInfoResult = await _wifiService.getTollGateInfo(ssid);
          return WifiConnectionState(
            isConnected: true,
            connectedSsid: ssid,
            isTollGate: isTollGate,
            tollGateResponse: tollGateInfoResult.getOrNull(),
          );
        }
        return WifiConnectionState(
          isConnected: true,
          connectedSsid: ssid,
          isTollGate: isTollGate,
        );
      },
    );
  }

  Future<Result<Unit, WifiConnectionError>> connectToNetwork({
    required String ssid,
    String? password,
  }) async {
    // Connect to the network
    final connectResult = await _wifiService.connectToNetwork(ssid, password);

    if (connectResult.isFailure) {
      return Failure(connectResult.getErrorOrNull()!);
    }

    ref.invalidateSelf();

    return const Success(unit);
  }

  Future<Result<Unit, WiFiDisconnectionError>> disconnectFromNetwork() async {
    final result = await _wifiService.disconnectFromNetwork();
    if (result.isSuccess) {
      ref.invalidateSelf();
    }
    return result;
  }
}
