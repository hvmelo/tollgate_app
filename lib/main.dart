import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'config/themes/theme_provider.dart';
import 'main_development.dart' as development;
import 'config/l10n/gen_l10n/app_localizations.dart';
import 'presentation/router/app_router.dart';
import 'config/themes/theme.dart';
import 'presentation/common/widgets/environment_banner.dart';

/// Default main method
Future<void> main() async {
  // Launch development config by default
  await development.main();
}

class MainApp extends ConsumerWidget {
  MainApp({super.key});

  final GoRouter _router = router();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
      builder: (context, child) {
        return EnvironmentBanner(child: child!);
      },
    );
  }
}
