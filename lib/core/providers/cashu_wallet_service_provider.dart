import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/models/cashu_wallet.dart';
import '../../data/services/cashu_wallet_service.dart';

part 'cashu_wallet_service_provider.g.dart';

@riverpod
CashuWalletService cashuWalletService(Ref ref) {
  return CashuWalletService();
}

@riverpod
Future<CashuWallet> cashuWalletInit(
  Ref ref,
  String? mintUrl,
) async {
  final walletService = ref.watch(cashuWalletServiceProvider);
  return await walletService.initializeWallet(mintUrl);
}
