import 'package:flutter/material.dart';

enum AppButtonVariant {
  primary,
  secondary,
  destructive,
  cancel,
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final buttonStyle = switch (variant) {
      AppButtonVariant.primary => ButtonStyle(
          backgroundColor: WidgetStateProperty.all(colorScheme.primary),
          foregroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 10),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      AppButtonVariant.secondary => ButtonStyle(
          backgroundColor: WidgetStateProperty.all(colorScheme.secondary),
          foregroundColor: WidgetStateProperty.all(colorScheme.onSecondary),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 10),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      AppButtonVariant.destructive => ButtonStyle(
          backgroundColor: WidgetStateProperty.all(colorScheme.error),
          foregroundColor: WidgetStateProperty.all(colorScheme.onError),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 10),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      AppButtonVariant.cancel => ButtonStyle(
          foregroundColor: WidgetStateProperty.all(colorScheme.onSurface),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 10),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          side: WidgetStateProperty.all(
            BorderSide(color: colorScheme.outline),
          ),
        ),
    };

    final buttonChild = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                variant == AppButtonVariant.cancel
                    ? colorScheme.onSurface
                    : colorScheme.onPrimary,
              ),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 14),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: switch (variant) {
        AppButtonVariant.cancel => OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          ),
        _ => ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          ),
      },
    );
  }
}
