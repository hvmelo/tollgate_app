import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../cards/app_card.dart';

/// A reusable QR code component with consistent styling across the app
class QrCodeCard extends StatelessWidget {
  final String data;
  final double size;
  final Color backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final List<BoxShadow>? boxShadow;

  const QrCodeCard({
    super.key,
    required this.data,
    this.size = 250,
    this.backgroundColor = Colors.white,
    this.foregroundColor,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      child: QrImageView(
        data: data,
        version: QrVersions.auto,
        size: size,
        backgroundColor: backgroundColor,
        eyeStyle: QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: foregroundColor ?? Colors.black,
        ),
        dataModuleStyle: QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: foregroundColor ?? Colors.black,
        ),
        errorStateBuilder: (context, error) {
          return Center(
            child: Text(
              'Error generating QR code',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          );
        },
      ),
    );
  }
}
