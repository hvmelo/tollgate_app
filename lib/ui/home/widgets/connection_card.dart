import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/wifi_connection_provider.dart';
import '../../../core/providers/wifi_scan_provider.dart';
import '../../core/router/routes.dart';
import '../../core/widgets/network_card.dart';
import '../../core/config/ui_constants.dart';

class ConnectionCard extends StatelessWidget {
  final WifiConnectionState connectionState;
  final WiFiScanState scanState;

  const ConnectionCard({
    super.key,
    required this.connectionState,
    required this.scanState,
  });

  @override
  Widget build(BuildContext context) {
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
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              if (connectionState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (connectionState.isConnected)
                _buildConnectedContent(context)
              else
                _buildNotConnectedContent(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectedContent(BuildContext context) {
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
                    ? colorScheme.primary.withAlpha(25)
                    : colorScheme.secondary.withAlpha(25),
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
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withAlpha(179),
                    ),
                  ),
                  Text(
                    connectionState.connectedSsid ?? 'Unknown Network',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
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
            '${connectionState.tollGateResponse?.satsPerMin ?? 0} sats/min',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withAlpha(179),
            ),
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
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurface.withAlpha(179),
            ),
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
                'Show ${tollGateNetworks.length - homeScreenMaxNetworksToShow} More',
                style: theme.textTheme.labelLarge?.copyWith(
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
