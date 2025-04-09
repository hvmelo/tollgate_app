import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../config/providers/service_providers.dart';
import '../../../../domain/wifi/errors/wifi_errors.dart';
import '../../../../domain/wifi/models/wifi_connection_info.dart';

part 'current_connection_state_stream_provider.freezed.dart';
part 'current_connection_state_stream_provider.g.dart';

@freezed
class CurrentConnectionState with _$CurrentConnectionState {
  const factory CurrentConnectionState({
    required bool isConnected,
    WifiConnectionInfo? connectionInfo,
    WifiGetCurrentConnectionError? getCurrentConnectionError,
    required bool isDisconnecting,
  }) = _CurrentConnectionState;
}

/// Provider that handles WiFi network scanning and updates every 10 seconds
@riverpod
Stream<CurrentConnectionState> currentConnectionStateStream(Ref ref) async* {
  final wifiService = ref.watch(wifiServiceProvider);

  while (true) {
    final result = await wifiService.getCurrentConnection();
    yield result.fold(
      onSuccess: (connectionInfo) {
        return CurrentConnectionState(
          isConnected: connectionInfo != null,
          connectionInfo: connectionInfo,
          isDisconnecting: false,
        );
      },
      onFailure: (error) {
        return CurrentConnectionState(
          isConnected: false,
          connectionInfo: null,
          isDisconnecting: false,
        );
      },
    );

    await Future.delayed(const Duration(seconds: 10));
  }
}
