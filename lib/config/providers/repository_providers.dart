import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/wallet/repositories/wallet_repository.dart';
import '../providers/data_source_providers.dart';

part 'repository_providers.g.dart';

@riverpod
Future<WalletRepository> walletRepository(Ref ref) async {
  final walletDataSource =
      await ref.watch(cashuWalletDataSourceProvider.future);
  return WalletRepositoryImpl(walletDataSource: walletDataSource);
}
