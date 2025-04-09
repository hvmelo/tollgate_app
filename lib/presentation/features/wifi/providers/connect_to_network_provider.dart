import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/result/result.dart';
import '../../../../core/result/unit.dart';
import '../../../../domain/wifi/errors/wifi_errors.dart';
import '../../../../domain/wifi/models/wifi_network.dart';
import '../interactors/wifi_interactor.dart';

part 'connect_to_network_provider.g.dart';

@riverpod
Future<Result<Unit, WifiConnectionError>> connectToNetwork(
    Ref ref, WiFiNetwork network,
    {String? password}) async {
  final interactor = WifiNetworkInteractor(ref);
  return interactor.connectOrRegister(network, password: password);
}
