import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/core/providers/tollgate_provider.dart';
import 'package:tollgate_app/core/utils/async_value_x.dart';
import 'package:tollgate_app/domain/models/wifi_connection_info.dart';
import 'package:tollgate_app/ui/core/utils/extensions/build_context_x.dart';

import '../../core/themes/colors.dart';
import 'connected_non_tollgate_card.dart';
import 'connected_tollgate_card.dart';
import 'not_connected_card.dart';

class ConnectionCard extends HookConsumerWidget {
  final WifiConnectionInfo? connectionInfo;
  final VoidCallback? onDisconnect;

  const ConnectionCard({
    super.key,
    required this.connectionInfo,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wi-Fi Connection',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
          Text(
            connectionInfo != null ? 'Connected' : 'Not Connected',
            style: context.textTheme.titleSmall?.copyWith(
              color: connectionInfo != null
                  ? AppColors.green
                  : context.colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          if (connectionInfo != null)
            if (connectionInfo!.isTollGate)
              _buildTollgateCard(ref, connectionInfo: connectionInfo!)
            else
              ConnectedNonTollgateCard(
                ssid: connectionInfo!.ssid ?? 'Unknown Network',
              )
          else
            const NotConnectedCard(),
        ],
      ),
    );
  }

  Widget _buildTollgateCard(
    WidgetRef ref, {
    required WifiConnectionInfo connectionInfo,
  }) {
    final routerIp = connectionInfo.gatewayIp;

    if (routerIp == null) {
      return ConnectedNonTollgateCard(
        ssid: connectionInfo.ssid ?? 'Unknown Network',
      );
    }

    final tollGateInfoAsync = ref.watch(tollgateInfoProvider(routerIp)).flatten;

    return tollGateInfoAsync.when(
      data: (tollGateInfo) => ConnectedTollgateCard(
        ssid: connectionInfo.ssid ?? 'Unknown Network',
        tollgateInfo: tollGateInfo,
      ),
      error: (error, stack) => ConnectedNonTollgateCard(
        ssid: connectionInfo.ssid ?? 'Unknown Network',
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
