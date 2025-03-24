import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tollgate_app/ui/core/utils/extensions/build_context_x.dart';

import '../../../data/services/connectivity/connectivity_service.dart';
import '../../../domain/models/tollgate_info.dart';
import '../../core/router/routes.dart';
import '../../core/utils/tollgate_utils.dart';

part 'connected_tollgate_card.g.dart';

@riverpod
Stream<bool> connectivityService(Ref ref) async* {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  yield* service.internetStatus;
}

class ConnectedTollgateCard extends ConsumerWidget {
  final String ssid;
  final TollgateInfo tollgateInfo;
  final VoidCallback? onDisconnect;

  const ConnectedTollgateCard({
    super.key,
    required this.ssid,
    required this.tollgateInfo,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasInternet =
        ref.watch(connectivityServiceProvider).valueOrNull ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // Network info section with enhanced design
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.wifi,
                  color: context.colorScheme.primary,
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
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withAlpha(179),
                      ),
                    ),
                    Text(
                      ssid,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.colorScheme.onSurface,
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
                  color: hasInternet
                      ? Colors.green.withAlpha(51)
                      : Colors.orange.withAlpha(51),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: hasInternet
                        ? Colors.green.withAlpha(77)
                        : Colors.orange.withAlpha(77),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasInternet ? Icons.check_circle : Icons.warning_rounded,
                      color: hasInternet ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasInternet ? 'Active' : 'No Access',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: hasInternet ? Colors.green : Colors.orange,
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

        // TollGate info card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          TollgateMetrics.formatMetrics(tollgateInfo),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface.withAlpha(179),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onDisconnect,
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
                label: const Text(
                  'Disconnect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(context.colorScheme.error),
                  padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 10)),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (hasInternet)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.push('${Routes.home}payment', extra: {
                      'ssid': ssid,
                      'tollgateInfo': tollgateInfo,
                    });
                  },
                  icon: const Icon(
                    Icons.bolt,
                    size: 14,
                  ),
                  label: const Text(
                    'Buy Access',
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
      ],
    );
  }
}
