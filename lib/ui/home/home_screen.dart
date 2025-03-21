import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/ui/core/utils/extensions/build_context_x.dart';

import '../../core/providers/wallet_provider.dart';
import '../../core/providers/wifi_connection_provider.dart';
import '../../core/providers/wifi_scan_provider.dart';
import 'widgets/connection_card.dart';
import 'widgets/wallet_card.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(wifiConnectionProvider);
    final walletState = ref.watch(walletProvider);
    final scanState = ref.watch(wifiScanProvider);

    useEffect(() {
      // Start scanning when not connected
      if (!connectionState.isConnected &&
          !scanState.isLoading &&
          scanState.networks.isEmpty) {
        Future.microtask(() => ref.read(wifiScanProvider.notifier).startScan());
      }
      return null;
    }, [
      connectionState.isConnected,
      scanState.isLoading,
      scanState.networks.isEmpty
    ]);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              // Connection Status Card
              ConnectionCard(
                connectionState: connectionState,
                scanState: scanState,
              ),

              // Wallet Card
              WalletCard(walletState: walletState),
            ],
          ),
        ),
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
}
