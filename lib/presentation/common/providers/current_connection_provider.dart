import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/providers/service_providers.dart';
import '../../../domain/errors/wifi_errors.dart';
import '../../../domain/models/wifi/wifi_connection_info.dart';

part 'current_connection_provider.freezed.dart';
part 'current_connection_provider.g.dart';

@freezed
class CurrentConnectionState with _$CurrentConnectionState {
  const factory CurrentConnectionState({
    required bool isConnected,
    WifiConnectionInfo? connectionInfo,
    WiFiDisconnectionError? disconnectionError,
    WifiGetCurrentConnectionError? getCurrentConnectionError,
    required bool isDisconnecting,
  }) = _CurrentConnectionState;
}

@riverpod
class CurrentConnection extends _$CurrentConnection {
  @override
  Future<CurrentConnectionState> build() async {
    final wifiService = ref.watch(wifiServiceProvider);
    final result = await wifiService.getCurrentConnection();
    return result.fold(
      (wifiConnectionInfo) => CurrentConnectionState(
        isConnected: wifiConnectionInfo != null,
        connectionInfo: wifiConnectionInfo,
        isDisconnecting: false,
      ),
      (failure) => throw failure,
    );
  }

  Future<void> disconnect() async {
    update((state) => state.copyWith(
          isDisconnecting: true,
        ));
    final wifiService = ref.watch(wifiServiceProvider);
    final result = await wifiService.disconnectFromNetwork();
    result.fold(
      (success) {
        update((state) => state.copyWith(
              isDisconnecting: false,
            ));
        ref.invalidateSelf();
      },
      (failure) {
        update((state) => state.copyWith(
              disconnectionError: failure,
              isDisconnecting: false,
            ));
      },
    );
  }
}
