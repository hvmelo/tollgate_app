import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/cashu_wallet.dart';
import '../../data/services/cashu_service.dart';

part 'cashu_wallet_provider.g.dart';

@Riverpod(keepAlive: true)
CashuService cashuService(Ref ref) {
  return CashuService();
}

@Riverpod(keepAlive: true)
String defaultMintUrl(Ref ref) {
  // Replace with your preferred default mint URL if needed
  return 'https://8333.space:3338';
}

@Riverpod(keepAlive: true)
CashuWallet cashuWallet(CashuWalletRef ref) {
  final cashuService = ref.watch(cashuServiceProvider);
  final defaultMintUrl = ref.watch(defaultMintUrlProvider);

  final wallet = CashuWallet(
    cashuService: cashuService,
    mintUrl: defaultMintUrl,
  );

  ref.onDispose(() {
    wallet.dispose();
  });

  return wallet;
}

@riverpod
Stream<int> walletBalance(Ref ref) {
  final wallet = ref.watch(cashuWalletProvider);
  return wallet.balanceStream;
}

@riverpod
Stream<List> walletTokens(Ref ref) {
  final wallet = ref.watch(cashuWalletProvider);
  return wallet.tokensStream;
}
