import 'package:cdk_flutter/cdk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';
import 'package:tollgate_app/presentation/common/widgets/cards/app_card.dart';
import 'package:tollgate_app/presentation/common/widgets/snackbar/app_snackbar.dart';

import '../../providers/current_mint_provider.dart';

class CurrentMintCard extends ConsumerWidget {
  const CurrentMintCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMintAsync = ref.watch(currentMintProvider);

    return switch (currentMintAsync) {
      AsyncData(:final value) => _buildMintCard(context, value),
      AsyncError(:final error) => _buildErrorCard(context, error),
      _ => const SizedBox(
          height: 100,
          child: Center(child: CircularProgressIndicator()),
        ),
    };
  }

  Widget _buildMintCard(BuildContext context, Mint? mint) {
    if (mint == null) {
      return _buildNoMintCard(context);
    }

    return AppCard(
      variant: AppCardVariant.info,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance,
                color: context.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Current Mint',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  mint.url,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                onPressed: () => _copyMintUrlToClipboard(context, mint.url),
                tooltip: 'Copy mint URL',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoMintCard(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'No Mint Connected',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Connect to a mint in settings to start minting tokens.',
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, Object error) {
    return AppCard(
      variant: AppCardVariant.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_rounded,
                color: context.colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Error Loading Mint',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            error.toString(),
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _copyMintUrlToClipboard(BuildContext context, String mintUrl) {
    Clipboard.setData(ClipboardData(text: mintUrl));
    AppSnackBar.showInfo(context, message: 'Mint URL copied to clipboard');
  }
}
