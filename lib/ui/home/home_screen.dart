import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/ui/core/utils/extensions/build_context_x.dart';

import '../../core/providers/wallet_provider.dart';
import '../core/providers/current_connection_provider.dart';
import 'widgets/connection_card.dart';
import 'widgets/wallet_card.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentConnectionStateAsync = ref.watch(currentConnectionProvider);
    final walletState = ref.watch(walletProvider);

    ref.listen(
        currentConnectionProvider.selectAsync((state) => state.isDisconnecting),
        (previous, next) async {
      if (previous == next) return;
      final isDisconnecting = await next;
      if (isDisconnecting) {
        if (context.mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Disconnecting...'),
                ],
              ),
            ),
          );
        }
      } else {
        if (context.mounted) {
          context.pop();
        }
      }
    });

    return currentConnectionStateAsync.when(
      data: (currentConnectionState) => Scaffold(
        extendBodyBehindAppBar: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                // Connection Status Card
                ConnectionCard(
                  connectionInfo: currentConnectionState.connectionInfo,
                  onDisconnect: () => _disconnectFromNetwork(context, ref),
                ),
                // Wallet Card
                WalletCard(walletState: walletState),
              ],
            ),
          ),
        ),
      ),
      error: (error, stack) => Text('Error: $error'),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          SizedBox(
            height: 60,
            child: Center(
              child: SvgPicture.asset(
                isDarkMode
                    ? 'assets/images/tollgate_logo_white.svg'
                    : 'assets/images/tollgate_logo_black.svg',
                width: 190,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Text(
            'Pay-as-You-Go Internet with Bitcoin',
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }

  void _disconnectFromNetwork(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final shouldDisconnect = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Disconnect'),
        content: const Text(
            'Are you sure you want to disconnect from this network?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (shouldDisconnect == true) {
      // Call the provider to disconnect
      await ref.read(currentConnectionProvider.notifier).disconnect();
    }
  }
}
