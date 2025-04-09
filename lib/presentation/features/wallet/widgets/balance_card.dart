import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/presentation/features/wallet/providers/wallet_balance_stream_provider.dart';

import '../../../common/widgets/cards/error_card.dart';
import '../../../common/widgets/cards/loading_card.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balanceAsync = ref.watch(walletBalanceStreamProvider);

    return switch (balanceAsync) {
      AsyncData(:final value) => _buildWidget(
          context,
          balance: value,
        ),
      AsyncError(:final error) => ErrorCard(
          message: 'Error loading balance',
          details: error.toString(),
          onRetry: () => ref.refresh(walletBalanceStreamProvider),
        ),
      _ => const LoadingCard(),
    };
  }

  Widget _buildWidget(BuildContext context, {required BigInt balance}) {
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
            'Current Balance',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: fadedTextColor,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                balance.toString(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'sats',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: fadedTextColor,
                      ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
