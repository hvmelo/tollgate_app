import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/core/utils/async_value_x.dart';

import 'package:tollgate_app/ui/core/utils/extensions/build_context_x.dart';

import '../../../core/providers/wifi_scan_provider.dart';
import '../../../domain/models/wifi_network.dart';
import '../../core/config/ui_constants.dart';
import '../../core/providers/wifi_providers.dart';
import '../../core/router/routes.dart';
import '../../core/widgets/network_card.dart';

class NotConnectedCard extends ConsumerWidget {
  const NotConnectedCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networksAsync = ref.watch(wifiNetworksStreamProvider).flatten;

    return networksAsync.when(
      data: (networks) {
        return _buildCard(context, ref, networks: networks);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
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
                    ref.read(connectToNetworkProvider(
                      network,
                    ));
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
