import 'package:flutter/material.dart';
import 'package:tollgate_app/presentation/common/extensions/build_context_x.dart';

/// Utility class for displaying snackbars in the app
class AppSnackBar {
  /// Show an info snackbar with the given message
  static void showInfo(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colorScheme.primary,
      ),
    );
  }

  /// Show a success snackbar with the given message
  static void showSuccess(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Show an error snackbar with the given message
  static void showError(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.colorScheme.error,
      ),
    );
  }
}
