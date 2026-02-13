import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_icon.dart';

class AppShellScreen extends StatelessWidget {
  const AppShellScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: AppIcon(
              name: 'analytics',
              semanticLabel: 'Home',
              size: 24,
            ),
            selectedIcon: AppIcon(
              name: 'analytics',
              semanticLabel: 'Home selected',
              size: 24,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: AppIcon(
              name: 'crown-coin',
              semanticLabel: 'Favorites',
              size: 24,
            ),
            selectedIcon: AppIcon(
              name: 'crown-coin',
              semanticLabel: 'Favorites selected',
              size: 24,
            ),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
