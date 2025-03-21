import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:async';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core/providers/wifi_connection_provider.dart';
import '../../../core/providers/wifi_scan_provider.dart';
import '../../core/router/routes.dart';
import '../../core/widgets/network_card.dart';
import '../../core/config/ui_constants.dart';

class ConnectionCard extends HookConsumerWidget {
  final WifiConnectionState connectionState;
  final WiFiScanState scanState;

  const ConnectionCard({
    super.key,
    required this.connectionState,
    required this.scanState,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: connectionState.isConnected
          ? () => context.push(Routes.connection)
          : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wi-Fi Connection',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 0),
            if (connectionState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (connectionState.isConnected)
              _buildConnectedContent(context, ref)
            else
              _buildNotConnectedContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedContent(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTollGate = connectionState.tollGateResponse != null;

    // Define the disconnect function first
    void disconnectFromNetwork() async {
      // Store context reference for the dialog
      final BuildContext dialogContext = context;

      // Show loading dialog
      showDialog(
        context: dialogContext,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
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

      try {
        // Call the provider to disconnect
        await ref.read(wifiConnectionProvider.notifier).disconnectFromNetwork();
      } finally {
        // Close the dialog safely using Navigator.pop with the mounted check
        if (dialogContext.mounted) {
          Navigator.of(dialogContext, rootNavigator: true).pop();
        }
      }
    }

    // Mock data for connected state - replace with real data in production
    final ValueNotifier<int> timeLeftMinutes =
        useState(21); // Mock time left in minutes
    final int amountSpentSats = 38; // Mock amount spent in sats
    final bool autoRenewEnabled = true; // Mock auto-renew status

    // Add countdown timer
    useEffect(() {
      final timer = Timer.periodic(const Duration(seconds: 15), (timer) {
        if (timeLeftMinutes.value > 0) {
          timeLeftMinutes.value -= 1;
        } else {
          timer.cancel();
          // When time is over, disconnect
          if (context.mounted) {
            disconnectFromNetwork();
          }
        }
      });

      return () => timer.cancel();
    }, []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Network info section with enhanced design
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isTollGate
                      ? colorScheme.primary.withAlpha(50)
                      : colorScheme.secondary.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.wifi,
                  color:
                      isTollGate ? colorScheme.primary : colorScheme.secondary,
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
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withAlpha(179),
                      ),
                    ),
                    Text(
                      connectionState.connectedSsid ?? 'Unknown Network',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Active',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Connection details section
        if (isTollGate) ...[
          // TollGate info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price info row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'TollGate Network',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${connectionState.tollGateResponse?.satsPerMin ?? 0} sats/min',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withAlpha(179),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: autoRenewEnabled
                            ? colorScheme.primary.withOpacity(0.15)
                            : colorScheme.onSurfaceVariant.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            autoRenewEnabled
                                ? Icons.autorenew
                                : Icons.autorenew_outlined,
                            color: autoRenewEnabled
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            autoRenewEnabled
                                ? 'Auto-renew on'
                                : 'Auto-renew off',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: autoRenewEnabled
                                  ? colorScheme.primary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: autoRenewEnabled
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Time and amount section
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time Left',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  color: timeLeftMinutes.value < 5
                                      ? colorScheme.error
                                      : colorScheme.primary,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${timeLeftMinutes.value} minutes',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: timeLeftMinutes.value < 5
                                        ? colorScheme.error
                                        : colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (timeLeftMinutes.value < 5)
                                  const SizedBox(width: 4),
                                if (timeLeftMinutes.value < 5)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: colorScheme.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Low',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: colorScheme.error,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount Spent',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.amber.shade700,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '$amountSpentSats sats',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons with enhanced styling
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: disconnectFromNetwork,
                  icon: Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Disconnect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('${Routes.home}payment', extra: {
                      'ssid': connectionState.connectedSsid,
                      'price': connectionState.tollGateResponse?.satsPerMin,
                    });
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 14,
                  ),
                  label: const Text(
                    'Add Time',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else
          // Not a TollGate Network design
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.secondary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.secondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Not a TollGate Network',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Connected to a regular Wi-Fi network',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: disconnectFromNetwork,
                    icon: Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Disconnect',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNotConnectedContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tollGateNetworks = scanState.tollGateNetworks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Not Connected',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.error,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        if (scanState.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (tollGateNetworks.isEmpty)
          Text(
            'No TollGate Networks Found',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          )
        else ...[
          ...tollGateNetworks.take(homeScreenMaxNetworksToShow).map(
                (network) => NetworkCard(
                  network: network,
                ),
              ),
          if (tollGateNetworks.length > homeScreenMaxNetworksToShow)
            TextButton(
              onPressed: () => context.push(Routes.scan),
              child: Text(
                '+${tollGateNetworks.length - homeScreenMaxNetworksToShow} TollGate Networks',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
        ],
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.push(Routes.scan),
            child: const Text('More Networks'),
          ),
        ),
      ],
    );
  }
}
