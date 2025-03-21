import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:tollgate_app/ui/core/utils/extensions/build_context_x.dart';

import '../../../core/providers/wifi_scan_provider.dart';
import '../core/widgets/network_card.dart';
import '../../../domain/models/wifi_network.dart';

class ScanScreen extends HookConsumerWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(wifiScanProvider);
    final isFirstLoad = useState(true);

    // Auto-start scan on first load
    useEffect(() {
      if (isFirstLoad.value) {
        isFirstLoad.value = false;
        Future.microtask(() => ref.read(wifiScanProvider.notifier).startScan());
      }
      return null;
    }, []);

    // Function to refresh the network list
    void refreshNetworks() {
      ref.read(wifiScanProvider.notifier).startScan();
    }

    // Get sorted networks with TollGate networks first
    final tollGateNetworks = scanState.tollGateNetworks;
    final regularNetworks = scanState.regularNetworks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Networks'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: scanState.isLoading ? null : refreshNetworks,
            tooltip: 'Refresh networks',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refreshNetworks();
          // Give some time for the refresh indicator to show
          await Future.delayed(const Duration(milliseconds: 600));
        },
        child: _buildBody(
            context, ref, scanState, tollGateNetworks, regularNetworks),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      WidgetRef ref,
      WiFiScanState scanState,
      List<WiFiNetwork> tollGateNetworks,
      List<WiFiNetwork> regularNetworks) {
    if (scanState.error != null) {
      return _buildErrorView(context, ref, scanState.error!, () {
        ref.read(wifiScanProvider.notifier).startScan();
      });
    }

    if (scanState.isLoading && scanState.networks.isEmpty) {
      return _buildLoadingView(context);
    }

    if (scanState.networks.isEmpty) {
      return _buildEmptyView(context, ref);
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      children: [
        // TollGate Networks Section
        if (tollGateNetworks.isNotEmpty) ...[
          _buildSectionHeader(
              context, 'TollGate Networks', context.colorScheme.primary),
          const SizedBox(height: 8),
          ...tollGateNetworks.map((network) => NetworkCard(network: network)),
          const SizedBox(height: 16),
        ],

        // Regular Networks Section
        if (regularNetworks.isNotEmpty) ...[
          _buildSectionHeader(
              context, 'Other Networks', context.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          ...regularNetworks
              .map((network) => _buildRegularNetworkCard(context, network)),
        ],

        // Show scan indicator at the bottom when refreshing
        if (scanState.isLoading) ...[
          const SizedBox(height: 16),
          const Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Scanning for networks...',
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
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

  Widget _buildRegularNetworkCard(BuildContext context, WiFiNetwork network) {
    // Calculate signal percentage
    final signalPercent =
        ((network.signalStrength + 100) / 100).clamp(0.0, 1.0);

    Color getSignalColor(double strength) {
      if (strength >= 0.75) return const Color(0xFF4CAF50); // Green
      if (strength >= 0.50) return const Color(0xFFFB8C00); // Orange
      return const Color(0xFFE57373); // Light Red
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Network Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.wifi,
              color: context.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Network Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  network.ssid,
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  network.securityType,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Signal Strength
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.signal_cellular_alt,
                color: getSignalColor(signalPercent),
                size: 20,
              ),
              const SizedBox(height: 2),
              Text(
                '${(signalPercent * 100).round()}%',
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
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
              ref.read(wifiScanProvider.notifier).startScan();
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
