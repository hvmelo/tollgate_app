import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/services/connectivity/connectivity_service.dart';

part 'connectivity_stream_provider.g.dart';

@riverpod
Stream<bool> connectivityStream(Ref ref) async* {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  yield* service.internetStatus;
}
