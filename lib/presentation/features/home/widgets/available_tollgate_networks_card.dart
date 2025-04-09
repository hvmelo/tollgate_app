import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/presentation/common/extensions/async_value_x.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';
import '../../../../domain/wifi/models/wifi_network.dart';
import '../../wifi/providers/scan_networks_stream_provider.dart';
import '../constants/home_constants.dart';
import '../../wifi/providers/connect_to_network_provider.dart';
import '../../../router/routes.dart';
import '../../wifi/widgets/network_card.dart';

class AvailableTollgateNetworksCard extends ConsumerWidget {
  const AvailableTollgateNetworksCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networksAsync = ref.watch(scanNetworksStreamProvider).flatten;

    return networksAsync.when(
      data: (networks) {
        return _buildCard(context, ref, networks: networks);
      },
      loading: () => SizedBox(
        height: 180,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Text('Error: $error'),
    );
  }

  Widget _buildCard(
    BuildContext context,
    WidgetRef ref, {
    required List<WiFiNetwork> networks,
  }) {
    final tollGateNetworks =
        networks.where((network) => network.isTollGate).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Available TollGate Networks:',
          style: context.textTheme.labelMedium?.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        if (networks.isEmpty)
          Text(
            'No TollGate Networks Found',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface,
            ),
          )
        else ...[
          ...tollGateNetworks.take(homeScreenMaxNetworksToShow).map(
                (network) => NetworkCard(
                  network: network,
                  onTap: () {
                    ref.read(connectToNetworkProvider(network));
                  },
                ),
              ),
          if (tollGateNetworks.length > homeScreenMaxNetworksToShow)
            TextButton(
              onPressed: () => context.go(Routes.scan),
              child: Text(
                '+${tollGateNetworks.length - homeScreenMaxNetworksToShow} TollGate Networks',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.primary,
                ),
              ),
            ),
        ],
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.go(Routes.scan),
            child: const Text('More Networks'),
          ),
        ),
      ],
    );
  }
}
