import 'package:flutter/foundation.dart';

import '../../config/app_config.dart';
import 'cashu_wallet/cashu_service.dart';
import 'mocks/mock_cashu_service.dart';
import 'mocks/mock_wifi_service.dart';
import 'payment/payment_service.dart';
import 'tollgate/mock_tollgate_service.dart';
import 'tollgate/tollgate_service.dart';
import 'wifi/wifi_service.dart';

/// Factory that provides services based on the current app environment
class ServiceFactory {
  static final ServiceFactory _instance = ServiceFactory._internal();

  factory ServiceFactory() {
    return _instance;
  }

  ServiceFactory._internal();

  /// Get the appropriate WiFi service based on app config
  WifiService getWifiService() {
    if (AppConfig.useMocks) {
      debugPrint('Using MockWifiService');
      return MockWifiService();
    } else {
      debugPrint('Using real WifiService');
      return WifiService();
    }
  }

  /// Get the appropriate Cashu wallet service based on app config
  CashuService getCashuService() {
    if (AppConfig.useMocks) {
      debugPrint('Using MockCashuService');
      return MockCashuService();
    } else {
      debugPrint('Using real CashuService');
      return CashuService();
    }
  }

  /// Get the appropriate Tollgate service based on app config
  TollgateService getTollgateService() {
    if (AppConfig.useMocks) {
      debugPrint('Using MockTollgateService');
      return MockTollgateService();
    } else {
      debugPrint('Using real TollgateService');
      return TollgateService();
    }
  }

  /// Get the appropriate Payment service based on app config
  PaymentService getPaymentService() {
    if (AppConfig.useMocks) {
      debugPrint('Using MockPaymentService');
      return MockPaymentService();
    } else {
      debugPrint('Using LivePaymentService');
      return LivePaymentService();
    }
  }
}
