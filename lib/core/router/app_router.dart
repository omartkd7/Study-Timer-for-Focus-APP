import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:regain/features/splash/presentation/screens/splash_screen.dart';
import 'package:regain/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:regain/features/timer/presentation/screens/timer_screen.dart';
import 'package:regain/features/stats/presentation/screens/stats_screen.dart';
import 'package:regain/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:regain/features/settings/presentation/screens/settings_screen.dart';
import 'package:regain/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:regain/features/music/presentation/screens/music_screen.dart';
import 'package:regain/features/achievements/presentation/screens/achievements_screen.dart';
import 'package:regain/shared/widgets/shell_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    // Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingScreen(),
    ),
    // Shell with bottom nav
    ShellRoute(
      builder: (_, state, child) => ShellScaffold(child: child),
      routes: [
        GoRoute(path: '/timer',        pageBuilder: (_, __) => const NoTransitionPage(child: TimerScreen())),
        GoRoute(path: '/stats',        pageBuilder: (_, __) => const NoTransitionPage(child: StatsScreen())),
        GoRoute(path: '/leaderboard',  pageBuilder: (_, __) => const NoTransitionPage(child: LeaderboardScreen())),
        GoRoute(path: '/settings',     pageBuilder: (_, __) => const NoTransitionPage(child: SettingsScreen())),
      ],
    ),
    // Full-screen routes (no nav bar)
    GoRoute(path: '/tasks',        builder: (_, __) => const TasksScreen()),
    GoRoute(path: '/music',        builder: (_, __) => const MusicScreen()),
    GoRoute(path: '/achievements', builder: (_, __) => const AchievementsScreen()),
  ],
);
