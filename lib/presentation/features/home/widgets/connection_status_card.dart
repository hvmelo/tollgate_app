import 'package:flutter/material.dart';
import 'package:tollgate_app/domain/wifi/models/wifi_connection_info.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';
import 'package:tollgate_app/config/themes/colors.dart';

class ConnectionStatusCard extends StatelessWidget {
  final WifiConnectionInfo? connectionInfo;
  final bool isTollGate;
  final bool hasInternet;

  const ConnectionStatusCard({
    super.key,
    required this.connectionInfo,
    required this.hasInternet,
    required this.isTollGate,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConnected = connectionInfo != null;
    final String ssid =
        connectionInfo?.ssid?.replaceAll('"', '') ?? 'Not Connected';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDarkMode
          ? context.colorScheme.primary.withAlpha(25)
          : Color(0xFFFAFAFA),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isConnected
                    ? AppColors.green.withAlpha(50)
                    : context.colorScheme.outline.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.wifi,
                    color: isConnected
                        ? AppColors.green
                        : context.colorScheme.outline,
                    size: 28,
                  ),
                  if (!isConnected)
                    Transform.rotate(
                      angle: -0.785398, // 45 degrees in radians
                      child: Container(
                        width: 2,
                        height: 36,
                        color: context.colorScheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isConnected ? 'Connected to' : 'Status',
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
                  if (isConnected) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTollGateBadge(context, isTollGate: isTollGate),
                        const SizedBox(width: 8),
                        _buildStatusBadge(context, hasInternet),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool hasInternet) {
    final Color badgeColor =
        hasInternet ? AppColors.green : context.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasInternet ? Icons.check_circle : Icons.warning_rounded,
            color: badgeColor,
            size: 14,
          ),
          const SizedBox(width: 2),
          Text(
            hasInternet ? 'Active' : 'No Internet',
            style: context.textTheme.bodySmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTollGateBadge(BuildContext context, {required bool isTollGate}) {
    final Color badgeColor =
        isTollGate ? AppColors.green : context.colorScheme.outline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isTollGate ? Icons.check_circle : Icons.warning_rounded,
            color: badgeColor,
            size: 14,
          ),
          const SizedBox(width: 2),
          Text(
            isTollGate ? 'TollGate' : 'Non-TollGate',
            style: context.textTheme.bodySmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
