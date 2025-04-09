import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'widgets/action_card.dart';
import 'widgets/balance_card.dart';
import 'widgets/recent_transactions_widget.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement QR scan
        },
        backgroundColor: Colors.purple,
        child: const Icon(
          Icons.qr_code_scanner_rounded,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 28),
                const BalanceCard(),
                const SizedBox(height: 16),
                _buildActionGrid(context),
                const SizedBox(height: 24),
                const RecentTransactionsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    final actionColors = {
      'send': Colors.blue,
      'receive': Colors.green,
      'mint': Colors.orange,
      'melt': Colors.red,
    };

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        // Send Button
        ActionCard(
          icon: Icons.arrow_upward_rounded,
          title: 'Send',
          subtitle: 'Send sats to others',
          color: actionColors['send']!,
          onTap: () {
            context.go('/wallet/send');
          },
        ),

        // Receive Button
        ActionCard(
          icon: Icons.arrow_downward_rounded,
          title: 'Receive',
          subtitle: 'Receive sats from others',
          color: actionColors['receive']!,
          onTap: () {
            // TODO: Navigate to receive screen
          },
        ),

        // Mint Button
        ActionCard(
          icon: Icons.local_atm_rounded,
          title: 'Mint',
          subtitle: 'Add funds to wallet',
          color: actionColors['mint']!,
          onTap: () {
            context.go('/wallet/mint');
          },
        ),

        // Melt Button
        ActionCard(
          icon: Icons.currency_bitcoin,
          title: 'Melt',
          subtitle: 'Convert to Bitcoin',
          color: actionColors['melt']!,
          onTap: () {
            // TODO: Navigate to melt screen
          },
        ),
      ],
    );
  }
}
