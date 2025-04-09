import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';
import 'package:tollgate_app/presentation/common/extensions/tollgate_info_x.dart';

import '../../../../domain/tollgate/models/tollgate_info.dart';
import '../../../common/widgets/buttons/app_button.dart';
import '../../../router/routes.dart';

class ConnectedTollgateCard extends ConsumerWidget {
  final String ssid;
  final TollGateInfo tollgateInfo;
  final bool hasInternet;
  final int remainingSeconds;

  const ConnectedTollgateCard({
    super.key,
    required this.ssid,
    required this.tollgateInfo,
    required this.hasInternet,
    this.remainingSeconds = 0,
  });

  String _formatRemainingTime() {
    if (remainingSeconds <= 0) {
      return 'No time remaining';
    }

    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasActiveSession = remainingSeconds > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorScheme.primary.withAlpha(25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          tollgateInfo.humanReadablePrice(),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurface.withAlpha(179),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (hasActiveSession) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Remaining Time',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _formatRemainingTime(),
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: remainingSeconds / 300,
                    minHeight: 8,
                    backgroundColor:
                        context.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AppButton(
                variant: AppButtonVariant.secondary,
                label: 'Top Up',
                onPressed: () {
                  context.push('${Routes.home}payment', extra: {
                    'ssid': ssid,
                    'tollgateInfo': tollgateInfo,
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
