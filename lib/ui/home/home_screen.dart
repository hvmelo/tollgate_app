import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/core/utils/async_value_x.dart';
import 'package:tollgate_app/ui/core/providers/connectivity_stream_provider.dart';
import 'package:tollgate_app/ui/core/utils/extensions/build_context_x.dart';

import '../../core/providers/tollgate_provider.dart';
import '../../core/providers/wallet_provider.dart';
import '../../domain/models/wifi_connection_info.dart';
import '../core/providers/current_connection_provider.dart';
import '../core/themes/colors.dart';
import 'widgets/connected_non_tollgate_card.dart';
import 'widgets/connected_tollgate_card.dart';
import 'widgets/connection_status_card.dart';
import 'widgets/available_tollgate_networks_card.dart';
import 'widgets/wallet_card.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentConnectionStateAsync = ref.watch(currentConnectionProvider);
    final hasInternet =
        ref.watch(connectivityStreamProvider).valueOrNull ?? false;
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  // Connection Status Card
                  _buildWifiConnectionSection(
                    context,
                    ref,
                    currentConnectionState: currentConnectionState,
                    hasInternet: hasInternet,
                  ),
                  const SizedBox(height: 30),
                  // Wallet Card
                  WalletCard(walletState: walletState),
                ],
              ),
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

  Widget _buildWifiConnectionSection(
    BuildContext context,
    WidgetRef ref, {
    required CurrentConnectionState currentConnectionState,
    required bool hasInternet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Wi-Fi Connection',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ConnectionStatusCard(
          connectionInfo: currentConnectionState.connectionInfo,
          hasInternet: hasInternet,
        ),
        const SizedBox(height: 16),
        if (currentConnectionState.connectionInfo != null)
          if (currentConnectionState.connectionInfo!.isTollGate)
            _buildTollgateCard(
              ref,
              connectionInfo: currentConnectionState.connectionInfo!,
              hasInternet: hasInternet,
            )
          else
            ConnectedNonTollgateCard(
              ssid: currentConnectionState.connectionInfo!.ssid ??
                  'Unknown Network',
            )
        else
          const AvailableTollgateNetworksCard(),
      ],
    );
  }

  Widget _buildTollgateCard(
    WidgetRef ref, {
    required WifiConnectionInfo connectionInfo,
    required bool hasInternet,
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
        hasInternet: hasInternet,
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
