import 'package:freezed_annotation/freezed_annotation.dart';

part 'wifi_errors.freezed.dart';

@freezed
class WifiGetCurrentConnectionError with _$WifiGetCurrentConnectionError {
  const factory WifiGetCurrentConnectionError.permissionDenied() =
      WifiGetCurrentConnectionPermissionDenied;
  const factory WifiGetCurrentConnectionError.failedToGetCurrentConnection(
      String? message) = WifiGetCurrentConnectionFailed;
}

@freezed
class WifiScanError with _$WifiScanError {
  const factory WifiScanError.locationServiceDisabled() =
      WifiLocationServiceDisabled;
  const factory WifiScanError.wifiServiceDisabled() = WifiServiceDisabled;
  const factory WifiScanError.permissionDenied() = WifiPermissionDenied;
  const factory WifiScanError.permissionRequiresUpgrade() =
      WifiPermissionRequiresUpgrade;
  const factory WifiScanError.scanUnsupported() = WifiScanUnsupported;
  const factory WifiScanError.scanFailed(String? message) = WifiScanFailed;
}

@freezed
class WifiConnectionError with _$WifiConnectionError {
  const factory WifiConnectionError.permissionDenied() =
      ConnectionPermissionDenied;
  const factory WifiConnectionError.connectionFailed(String? message) =
      ConnectionFailed;
  const factory WifiConnectionError.platformNotSupported() =
      ConnectionPlatformNotSupported;
}

@freezed
class WifiRegistrationError with _$WifiRegistrationError {
  const factory WifiRegistrationError.registrationFailed(String? message) =
      RegistrationFailed;
}

@freezed
class WiFiDisconnectionError with _$WiFiDisconnectionError {
  const factory WiFiDisconnectionError.disconnectionFailed(String? message) =
      DisconnectionFailed;
}

@freezed
class TollGateVerificationError with _$TollGateVerificationError {
  const factory TollGateVerificationError.verificationFailed(String? message) =
      TollGateVerificationFailed;
}

@freezed
class TollGateInfoResponseError with _$TollGateInfoResponseError {
  const factory TollGateInfoResponseError.responseFailed(String? message) =
      TollGateInfoResponseFailed;
}

@freezed
class TollGatePaymentError with _$TollGatePaymentError {
  const factory TollGatePaymentError.paymentFailed(String? message) =
      TollGatePaymentFailed;
}
