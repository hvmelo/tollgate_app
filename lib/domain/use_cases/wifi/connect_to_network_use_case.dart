// import '../../../core/utils/result.dart';
// import '../../../core/utils/unit.dart';
// import '../../../data/services/wifi/wifi_service.dart';
// import '../../errors/wifi_errors.dart';
// import '../../models/wifi_network.dart';

// class ConnectToNetworkUseCase {
//   final WifiService _wifiService;

//   ConnectToNetworkUseCase({required WifiService wifiService})
//       : _wifiService = wifiService;

//   Future<Result<Unit, WifiConnectionError>> execute(WiFiNetwork network) async {
//     // First we need to check if the network is registered
//     final isRegistered = await _wifiService.isNetworkRegistered(network);
//     if (!isRegistered) {
//       return Failure(WifiConnectionError.networkNotRegistered());
//     }
//   }
// }
