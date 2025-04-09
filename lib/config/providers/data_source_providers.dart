import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/data_sources/cashu_wallet_data_source.dart';

part 'data_source_providers.g.dart';

@Riverpod(keepAlive: true)
Future<CashuWalletDataSource> cashuWalletDataSource(Ref ref) async {
  return CashuWalletDataSource.init();
}
