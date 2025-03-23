import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tollgate_app/core/utils/async_value_x.dart';
import 'package:tollgate_app/ui/core/utils/extensions/build_context_x.dart';

import '../../../core/providers/wifi_scan_provider.dart';
import '../core/widgets/network_card.dart';
import '../../../domain/models/wifi_network.dart';

class ScanScreen extends HookConsumerWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networksAsync = ref.watch(scanWifiNetworksProvider).flatten;
    final isFirstLoad = useState(true);

    // Function to refresh the network list
    Future<void> refreshNetworks() async {
      ref.invalidate(scanWifiNetworksProvider);
    }

    return networksAsync.when(
      data: (networks) {
        final tollGateNetworks =
            networks.where((network) => network.isTollGate).toList();
        final regularNetworks =
            networks.where((network) => !network.isTollGate).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Available Networks'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: refreshNetworks,
                tooltip: 'Refresh networks',
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: refreshNetworks,
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              children: [
                if (networks.isEmpty) ...[
                  _buildEmptyView(context, ref),
                ],

                // TollGate Networks Section
                if (tollGateNetworks.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'TollGate Networks',
                    context.colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  ...tollGateNetworks
                      .map((network) => NetworkCard(network: network)),
                  const SizedBox(height: 16),
                ],

                // Regular Networks Section
                if (regularNetworks.isNotEmpty) ...[
                  _buildSectionHeader(
                    context,
                    'Other Networks',
                    context.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  ...regularNetworks
                      .map((network) => NetworkCard(network: network)),
                ],
              ],
            ),
          ),
        );
      },
      error: (error, stack) =>
          _buildErrorView(context, ref, error.toString(), refreshNetworks),
      loading: () => _buildLoadingView(context),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, Color color) {
    return Row(
      children: [
        Icon(
          title.contains('TollGate') ? Icons.bolt : Icons.wifi,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(context.colorScheme.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Scanning for Networks',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Text(
              'Looking for TollGate Wi-Fi access points...',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.wifi_off,
            size: 64,
            color: context.colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Networks Found',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh and scan again',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(scanWifiNetworksProvider);
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Scan Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(
      BuildContext context, WidgetRef ref, String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: context.colorScheme.error.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Scan Error',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              error,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
