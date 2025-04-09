import 'dart:io';

import 'package:cdk_flutter/cdk_flutter.dart';
import 'package:path_provider/path_provider.dart';

class CashuWalletDataSource {
  final MultiMintWallet _wallet;

  CashuWalletDataSource._(this._wallet);

  static Future<CashuWalletDataSource> init() async {
    await CdkFlutter.init();
    final path = await getApplicationDocumentsDirectory();
    final seedFile = File('${path.path}/seed.txt');

    String seed;
    if (await seedFile.exists()) {
      seed = await seedFile.readAsString();
    } else {
      seed = generateHexSeed();
      await seedFile.writeAsString(seed);
    }

    final db =
        await WalletDatabase.newInstance(path: '${path.path}/wallet.sqlite');
    final wallet = await MultiMintWallet.newFromHexSeed(
      unit: 'sat',
      seed: seed,
      localstore: db,
    );

    return CashuWalletDataSource._(wallet);
  }

  MultiMintWallet get wallet => _wallet;
}
