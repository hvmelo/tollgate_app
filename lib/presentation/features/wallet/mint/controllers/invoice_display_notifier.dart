import 'package:cdk_flutter/cdk_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../domain/wallet/value_objects/mint_amount.dart';
import '../../providers/mint_transactions_provider.dart';

part 'invoice_display_notifier.g.dart';

/// Notifier for the invoice display
@riverpod
class InvoiceDisplayNotifier extends _$InvoiceDisplayNotifier {
  @override
  Stream<MintQuote> build(Mint mint, MintAmount amount) async* {
    // Watch the mintQuote stream

    // Watch the mintQuote stream
    final stream = ref.watch(mintQuoteStreamProvider(mint, amount));

    // Transform AsyncValue<Result<MintQuote, Error>> into Stream<MintQuote>
    // using the yield* pattern to delegate to the underlying stream
    yield* stream.when(
      data: (result) async* {
        result.fold(
          onSuccess: (mintQuote) => mintQuote,
          onFailure: (error) => throw error,
        );
      },
      loading: () async* {
        // Nothing to emit while loading
      },
      error: (error, stack) async* {
        throw error;
      },
    );
  }
}
