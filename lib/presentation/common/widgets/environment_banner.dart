import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../config/environment/app_environment.dart';
import '../../../config/environment/environment_provider.dart';

/// A banner that displays the current environment mode (development or staging)
/// at the top right corner of the app
class EnvironmentBanner extends ConsumerWidget {
  /// The child widget to wrap with the banner
  final Widget child;

  /// Creates an environment banner
  const EnvironmentBanner({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environment = ref.watch(environmentConfigProvider);

    if (environment == AppEnvironment.production) {
      return child;
    }

    return Banner(
      message: environment == AppEnvironment.development ? 'DEV' : 'STAGING',
      location: BannerLocation.topEnd,
      color: environment == AppEnvironment.development
          ? Colors.red
          : Colors.yellow,
      child: child,
    );
  }
}
