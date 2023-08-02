import 'package:cybersecurity_its_app/views/operational_context_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cybersecurity_its_app/widgets/bottom_nav_bar.dart';
import 'package:cybersecurity_its_app/views/home_screen.dart';
import 'package:cybersecurity_its_app/views/device_detail_screen.dart';
import 'package:cybersecurity_its_app/views/help_screen.dart';
import 'package:cybersecurity_its_app/views/settings_screen.dart';
import 'package:cybersecurity_its_app/views/login_screen_temp.dart';
// private navigators
final _rootNavigatorKey = GlobalKey<NavigatorState>(); 
final _shellNavigatorAKey = GlobalKey<NavigatorState>(debugLabel: 'shellA');
final _shellNavigatorBKey = GlobalKey<NavigatorState>(debugLabel: 'shellB');
final _shellNavigatorCKey = GlobalKey<NavigatorState>(debugLabel: 'shellC');
final _shellNavigatorDKey = GlobalKey<NavigatorState>(debugLabel: 'shellD');

/// The route configuration.
final goRouter = GoRouter(
  initialLocation: '/Home',
  navigatorKey: _rootNavigatorKey,
  routes: [
    // Stateful nested navigation based on:
    // https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // the UI shell
        return BottomNavBar(
            navigationShell: navigationShell);
      },
      branches: [
        // first branch (Home)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAKey,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/Home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(label: 'ITS Device Security', detailsPath: '/Home/details', settingsPath: '/Home/settings',),
              ),
              routes: [
                // child route
                GoRoute(
                  path: 'details',
                  builder: (context, state) =>
                      const DetailsScreen(label: 'Select Vendor and Model'),
                ),
                GoRoute(
                  path: 'settings',
                  pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(label: 'Settings'),
              ),
            ),
                
              ],
            ),
          ],
        ),
        // second branch (Help)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorBKey,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/Help',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HelpScreen(label: 'Report an Issue'),
              ),
            ),
          ],
        ),
        // third branch (Operational Context)
        StatefulShellBranch(
          navigatorKey: _shellNavigatorCKey,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/OpContext',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: OpContextScreen(label: 'Operational Context'),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorDKey,
          routes: [
            // top route inside branch
            GoRoute(
              path: '/Login',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: LoginScreen(label: 'Login'),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);