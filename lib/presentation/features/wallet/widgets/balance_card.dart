import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';
import 'package:tollgate_app/presentation/features/wallet/providers/wallet_balance_stream_provider.dart';

import '../../../common/widgets/cards/error_card.dart';
import '../../../common/widgets/cards/loading_card.dart';
import '../providers/local_ecash_providers.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(walletBalanceStreamProvider);
    final ecashBalance = ref.watch(ecashLocalTokenStreamProvider);

    return switch (balanceAsync) {
      AsyncData(:final value) => _buildWidget(
          context,
          mintsBalance: value,
          ecashBalance: ecashBalance.value?.amount ?? BigInt.zero,
        ),
      AsyncError(:final error) => ErrorCard(
          message: 'Error loading balance',
          details: error.toString(),
          onRetry: () => ref.refresh(walletBalanceStreamProvider),
        ),
      _ => const LoadingCard(),
    };
  }

  Widget _buildWidget(BuildContext context,
      {required BigInt mintsBalance, required BigInt ecashBalance}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fadedTextColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Balance',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: context.colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBalanceItem(
                  context, 'In Mints', mintsBalance, fadedTextColor, textColor),
              _buildBalanceItem(context, 'Local eCash', ecashBalance,
                  fadedTextColor, textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(BuildContext context, String label, BigInt balance,
      Color fadedTextColor, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: fadedTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              balance.toString(),
              style: context.textTheme.titleLarge?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'sats',
              style: context.textTheme.bodyMedium?.copyWith(
                color: fadedTextColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
