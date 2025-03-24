import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'available_tollgate_networks_card.dart';

class ConnectedNonTollgateCard extends ConsumerWidget {
  final String ssid;
  final VoidCallback? onDisconnect;

  const ConnectedNonTollgateCard({
    super.key,
    required this.ssid,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Not a TollGate Network info
        // AppCard(
        //   variant: AppCardVariant.info,
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Row(
        //         children: [
        //           Icon(
        //             Icons.info_outline,
        //             color: context.colorScheme.secondary,
        //             size: 18,
        //           ),
        //           const SizedBox(width: 8),
        //           Text(
        //             'Not a TollGate Network',
        //             style: context.textTheme.bodyMedium?.copyWith(
        //               color: context.colorScheme.secondary,
        //               fontWeight: FontWeight.w600,
        //             ),
        //           ),
        //         ],
        //       ),
        //       const SizedBox(height: 8),
        //       Text(
        //         'Connected to a regular Wi-Fi network',
        //         style: context.textTheme.bodySmall?.copyWith(
        //           color: context.colorScheme.onSurfaceVariant,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // const SizedBox(height: 16),
        AvailableTollgateNetworksCard(),
      ],
    );
  }
}
