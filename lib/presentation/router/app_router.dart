import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tollgate_app/presentation/features/map/map_screen.dart';
import 'package:tollgate_app/presentation/features/payment/payment_screen.dart';
import 'package:tollgate_app/presentation/features/settings/settings_screen.dart';

import '../features/connection_details/connection_screen.dart';
import '../features/home/home_screen.dart';
import '../features/network_scan/scan_screen.dart';
import '../features/wallet/wallet_screen.dart';
import '../common/layout/navigation_shell.dart';
import 'routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final homeNavigatorKey = GlobalKey<NavigatorState>();
final walletNavigatorKey = GlobalKey<NavigatorState>();
final settingsNavigatorKey = GlobalKey<NavigatorState>();
final mapNavigatorKey = GlobalKey<NavigatorState>();

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
                  path: Routes.home,
                  pageBuilder: (context, state) => CustomTransitionPage(
                    child: const HomeScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            _buildFadeInTransition(animation, child),
                  ),
                  routes: [
                    GoRoute(
                      path: 'connection',
                      pageBuilder: (context, state) => CustomTransitionPage(
                        child: const ConnectionScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) =>
                                _buildSlideLeftTransition(animation, child),
                      ),
                    ),
                    GoRoute(
                      path: 'scan',
                      pageBuilder: (context, state) => CustomTransitionPage(
                        child: const ScanScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) =>
                                _buildSlideLeftTransition(animation, child),
                      ),
                    ),
                    GoRoute(
                      path: 'payment',
                      pageBuilder: (context, state) {
                        final Map<String, dynamic>? networkData =
                            state.extra as Map<String, dynamic>?;

                        return CustomTransitionPage(
                          child: PaymentScreen(networkData: networkData),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) =>
                                  _buildSlideLeftTransition(animation, child),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatefulShellBranch(
              navigatorKey: mapNavigatorKey,
              routes: [
                GoRoute(
                  path: Routes.map,
                  pageBuilder: (context, state) => CustomTransitionPage(
                    child: const MapScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) =>
                            _buildFadeInTransition(animation, child),
                  ),
                ),
              ],
            ),
            // StatefulShellBranch(
            //   navigatorKey: walletNavigatorKey,
            //   routes: [
            //     GoRoute(
            //       path: Routes.wallet,
            //       pageBuilder: (context, state) => CustomTransitionPage(
            //         child: const WalletScreen(),
            //         transitionsBuilder:
            //             (context, animation, secondaryAnimation, child) =>
            //                 _buildFadeInTransition(animation, child),
            //       ),
            //     ),
            //   ],
            // ),
            StatefulShellBranch(
              navigatorKey: settingsNavigatorKey,
              routes: [
                GoRoute(
                  path: Routes.settings,
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
