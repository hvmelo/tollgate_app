import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tollgate_app/ui/settings/settings_screen.dart';

import '../../home/home_screen.dart';
import '../../wallet/wallet_screen.dart';
import '../navigation/navigation_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final homeNavigatorKey = GlobalKey<NavigatorState>();
final walletNavigatorKey = GlobalKey<NavigatorState>();
final settingsNavigatorKey = GlobalKey<NavigatorState>();

/// Top go_router entry point.
GoRouter router() => GoRouter(
      initialLocation: '/',
      navigatorKey: rootNavigatorKey,
      debugLogDiagnostics: true,
      routes: [
        StatefulShellRoute.indexedStack(
          pageBuilder: (context, state, shell) => CustomTransitionPage(
            key: state.pageKey,
            child: NavigationShell(navigationShell: shell),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
          branches: [
            StatefulShellBranch(
              navigatorKey: homeNavigatorKey,
              routes: [
                GoRoute(
                  path: '/',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    child: const HomeScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            _buildFadeInTransition(animation, child),
                  ),
                  routes: [
                    GoRoute(
                      path: '/wallet',
                      pageBuilder: (context, state) => CustomTransitionPage(
                        child: const WalletScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) =>
                                _buildSlideLeftTransition(animation, child),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: settingsNavigatorKey,
              routes: [
                GoRoute(
                  path: '/settings',
                  pageBuilder: (context, state) => CustomTransitionPage(
                    child: const SettingsScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            _buildFadeInTransition(animation, child),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

SlideTransition _buildSlideLeftTransition(
    Animation<double> animation, Widget child) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );
}

FadeTransition _buildFadeInTransition(
    Animation<double> animation, Widget child) {
  return FadeTransition(
    opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
    child: child,
  );
}
