import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/providers/wallet_provider.dart';
import '../../core/providers/wifi_connection_provider.dart';
import '../core/router/routes.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connectionState = ref.watch(wifiConnectionProvider);
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // TollGate Logo and Title
              const SizedBox(height: 24),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.asset(
                          'assets/images/tollgate_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'TollGate',
                      style: theme.textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Connection Status Card
              _buildConnectionCard(context, connectionState),
              const SizedBox(height: 24),

              // Wallet Card
              _buildWalletCard(context, walletState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionCard(
      BuildContext context, WifiConnectionState connectionState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: connectionState.isConnected
            ? () => context.push(Routes.connection)
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wi-Fi Connection',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              if (connectionState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (connectionState.isConnected)
                _buildConnectedStatus(context, connectionState)
              else
                _buildNotConnectedStatus(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedStatus(
      BuildContext context, WifiConnectionState connectionState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTollGate = connectionState.tollGateResponse != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isTollGate
                    ? colorScheme.primary.withOpacity(0.1)
                    : colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.wifi,
                color: isTollGate ? colorScheme.primary : colorScheme.secondary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connected to',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    connectionState.connectedSsid ?? 'Unknown Network',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isTollGate) ...[
          Text(
            'TollGate Network',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${connectionState.tollGateResponse?.pricePerMb ?? 0} ${connectionState.tollGateResponse?.priceUnit ?? 'sats'}/MB',
            style: theme.textTheme.bodySmall,
          ),
        ] else
          Text(
            'Not a TollGate Network',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Tap for details',
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }

  Widget _buildNotConnectedStatus(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.wifi_off,
          size: 48,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'Not Connected',
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.push(Routes.scan),
            child: const Text('Scan Networks'),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard(BuildContext context, WalletState walletState) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => context.push(Routes.wallet),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cashu Wallet',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              if (walletState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Balance',
                            style: theme.textTheme.bodySmall,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${walletState.balance}',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'sats',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tap to manage wallet',
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
