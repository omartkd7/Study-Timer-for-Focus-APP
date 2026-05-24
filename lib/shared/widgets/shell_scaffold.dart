import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  int _index(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/stats'))       return 1;
    if (loc.startsWith('/leaderboard')) return 2;
    if (loc.startsWith('/settings'))   return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/timer'); break;
            case 1: context.go('/stats'); break;
            case 2: context.go('/leaderboard'); break;
            case 3: context.go('/settings'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.timer_outlined),      selectedIcon: Icon(Icons.timer),      label: 'Focus'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined),  selectedIcon: Icon(Icons.bar_chart),  label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.leaderboard_outlined),selectedIcon: Icon(Icons.leaderboard),label: 'Ranks'),
          NavigationDestination(icon: Icon(Icons.settings_outlined),   selectedIcon: Icon(Icons.settings),   label: 'Settings'),
        ],
      ),
    );
  }
}
