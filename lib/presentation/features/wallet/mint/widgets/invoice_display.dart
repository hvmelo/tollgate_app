import 'package:cdk_flutter/cdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';

import '../../../../../config/themes/colors.dart';
import '../../../../../core/result/result.dart';
import '../../../../../domain/wallet/value_objects/mint_amount.dart';
import '../../../../common/widgets/buttons/app_button.dart';
import '../../../../common/widgets/qr_code/qr_code_card.dart';
import '../../../../common/widgets/snackbar/app_snackbar.dart';
import '../../providers/current_mint_provider.dart';
import '../../providers/mint_transactions_provider.dart';

class InvoiceDisplay extends ConsumerWidget {
  final Mint mint;
  final MintAmount amount;
  final VoidCallback onClose;

  const InvoiceDisplay({
    super.key,
    required this.mint,
    required this.amount,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMintAsync = ref.watch(currentMintProvider);
    switch (currentMintAsync) {
      case AsyncData(:final value):
        if (value == null) {
          return ErrorWidget(Exception('Mint not found'));
        }
        final mintQuoteAsync = ref.watch(mintQuoteStreamProvider(
          mint,
          amount,
        ));

        ref.listen(
            mintQuoteStreamProvider(
              mint,
              amount,
            ), (previous, current) {
          switch (current) {
            case AsyncData(:final value):
              switch (value) {
                case Ok(value: final mintQuote):
                  if (mintQuote.state == MintQuoteState.issued) {
                    Future.delayed(const Duration(seconds: 1), () {
                      onClose();
                    });
                  }
                case Failure(:final failure):
                  throw failure;
              }
            case AsyncError(:final error):
              throw error;
            default:
              return;
          }
        });

        return switch (mintQuoteAsync) {
          AsyncData(value: final result) => switch (result) {
              Ok(value: final mintQuote) =>
                _buildWidget(context, mintQuote: mintQuote),
              Failure(:final failure) => ErrorWidget(failure),
            },
          AsyncError(:final error) => ErrorWidget(error),
          AsyncLoading() => const Center(child: CircularProgressIndicator()),
          _ => const SizedBox(),
        };
      case AsyncError(:final error):
        return ErrorWidget(error);
      case _:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildWidget(
    BuildContext context, {
    required MintQuote mintQuote,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simple amount display
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 24),
          child: Row(
            children: [
              Icon(
                Icons.bolt,
                color: AppColors.actionColors['receive'],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '${amount.value} sats',
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.actionColors['receive'],
                ),
              ),
            ],
          ),
        ),

        // QR Code card
        Column(
          children: [
            QrCodeCard(
              data: mintQuote.request,
              size: MediaQuery.of(context).size.width - 82,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              borderRadius: BorderRadius.circular(24),
              boxShadow: null,
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: AppButton(
                      label: context.l10n.mintScreenCopyInvoice,
                      onPressed: () => _copyInvoiceToClipboard(
                        context,
                        mintQuote.request,
                      ),
                      icon: Icons.copy,
                      variant: AppButtonVariant.primary,
                      fullWidth: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 56,
                  child: AppButton(
                    label: context.l10n.mintScreenClose,
                    onPressed: onClose,
                    icon: Icons.close,
                    variant: AppButtonVariant.secondary,
                    fullWidth: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void _copyInvoiceToClipboard(BuildContext context, String invoice) {
    Clipboard.setData(ClipboardData(text: invoice));
    AppSnackBar.showInfo(context,
        message: context.l10n.mintScreenInvoiceCopied);
  }
}
