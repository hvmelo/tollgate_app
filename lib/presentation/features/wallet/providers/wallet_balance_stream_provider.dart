import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../config/providers/repository_providers.dart';

part 'wallet_balance_stream_provider.g.dart';

@riverpod
Stream<BigInt> walletBalanceStream(Ref ref) async* {
  final walletRepository = await ref.watch(walletRepositoryProvider.future);
  yield* walletRepository.getBalanceStream();
}
