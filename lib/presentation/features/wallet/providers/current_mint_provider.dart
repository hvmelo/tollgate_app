import 'package:cdk_flutter/cdk_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../config/providers/repository_providers.dart';
import '../../../../config/providers/service_providers.dart';
import '../../../../domain/wallet/value_objects/mint_url.dart';

part 'current_mint_provider.g.dart';

@riverpod
class CurrentMint extends _$CurrentMint {
  @override
  Future<Mint?> build() async {
    final cashuLocalPreferences = ref.watch(cashuLocalPreferencesProvider);
    final mintUrl = cashuLocalPreferences.getCurrentMintUrl();
    if (mintUrl == null) {
      return null;
    }
    final mintRepo = await ref.watch(walletRepositoryProvider.future);
    final mintsResult = await mintRepo.listMints();
    return mintsResult.fold(
      onSuccess: (mints) {
        return mints.where((m) => m.url == mintUrl).firstOrNull;
      },
      onFailure: (failure) => null,
    );
  }

  Future<void> setCurrentMint(String mintUrl) async {
    final cashuLocalPreferences = ref.watch(cashuLocalPreferencesProvider);
    final mintUrlResult = MintUrl.create(mintUrl);

    mintUrlResult.fold(
      onSuccess: (mintUrl) async {
        await cashuLocalPreferences.saveCurrentMintUrl(mintUrl.value);
        final mintRepo = await ref.watch(walletRepositoryProvider.future);
        final mintsResult = await mintRepo.listMints();
        state = AsyncData(mintsResult.fold(
          onSuccess: (mints) => mints.firstWhere((m) => m.url == mintUrl.value),
          onFailure: (failure) => null,
        ));
      },
      onFailure: (failure) => state = AsyncError(failure, StackTrace.current),
    );
  }
}
