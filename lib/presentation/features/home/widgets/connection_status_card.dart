import 'package:flutter/material.dart';
import 'package:tollgate_app/domain/models/wifi/wifi_connection_info.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';

class ConnectionStatusCard extends StatelessWidget {
  final WifiConnectionInfo? connectionInfo;
  final bool hasInternet;

  const ConnectionStatusCard({
    super.key,
    required this.connectionInfo,
    required this.hasInternet,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConnected = connectionInfo != null;
    final String ssid = connectionInfo?.ssid ?? 'Not Connected';

    return Card(
      color: context.colorScheme.primary.withAlpha(25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isConnected
                    ? context.colorScheme.secondary.withAlpha(50)
                    : context.colorScheme.outline.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.wifi,
                    color: isConnected
                        ? context.colorScheme.secondary
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
                ],
              ),
            ),
            if (isConnected) _buildStatusBadge(context, hasInternet),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, bool hasInternet) {
    final Color badgeColor = hasInternet ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withAlpha(51),
        borderRadius: BorderRadius.circular(16),
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
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            hasInternet ? 'Active' : 'No Internet',
            style: context.textTheme.bodySmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
