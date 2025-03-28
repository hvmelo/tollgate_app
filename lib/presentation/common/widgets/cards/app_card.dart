import 'package:flutter/material.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';

enum AppCardVariant {
  primary,
  info,
  warning,
  error,
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final AppCardVariant variant;
  final bool showBorder;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.onTap,
    this.variant = AppCardVariant.primary,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final (Color bgColor, Color borderColor) = switch (variant) {
      AppCardVariant.primary => (
          colorScheme.primary.withAlpha(25),
          colorScheme.primary.withAlpha(51),
        ),
      AppCardVariant.info => (
          colorScheme.secondary.withAlpha(25),
          colorScheme.secondary.withAlpha(51),
        ),
      AppCardVariant.warning => (
          colorScheme.error.withAlpha(25),
          colorScheme.error.withAlpha(51),
        ),
      AppCardVariant.error => (
          colorScheme.error.withAlpha(25),
          colorScheme.error.withAlpha(51),
        ),
    };

    return Card(
      color: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: showBorder
            ? BorderSide(color: borderColor, width: 1)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
