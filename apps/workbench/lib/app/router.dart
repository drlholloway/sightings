import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/curves/curves_screen.dart';
import '../features/history/history_screen.dart';
import '../features/history/reading_detail_screen.dart';
import '../features/identify/identify_screen.dart';
import '../features/log/log_screen.dart';
import '../features/parts/bin_screen.dart';
import '../features/parts/part_screen.dart';
import '../features/parts/parts_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/app_shell.dart';

final _rootKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/identify',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/identify', builder: (c, s) => const IdentifyScreen()),
        GoRoute(
          path: '/curves',
          builder: (c, s) => CurvesScreen(
            sweepId: int.tryParse(s.uri.queryParameters['sweep'] ?? ''),
          ),
        ),
        GoRoute(
          path: '/history',
          builder: (c, s) => const HistoryScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (c, s) =>
                  ReadingDetailScreen(id: int.parse(s.pathParameters['id']!)),
            ),
          ],
        ),
        GoRoute(
          path: '/parts',
          builder: (c, s) => const PartsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (c, s) =>
                  PartScreen(id: int.parse(s.pathParameters['id']!)),
            ),
          ],
        ),
        GoRoute(
          path: '/bins/:id',
          builder: (c, s) => BinScreen(id: int.parse(s.pathParameters['id']!)),
        ),
        GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        GoRoute(path: '/log', builder: (c, s) => const LogScreen()),
      ],
    ),
  ],
);
