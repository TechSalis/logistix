import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// DispatcherPage acts as the Shell for the dispatcher module's tabs.
/// It uses a BottomNavigationBar with StatefulNavigationShell to preserve tab state.
class DispatcherPage extends StatelessWidget {
  const DispatcherPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<NavigationDestination> _navItems = [
    NavigationDestination(
      icon: Icon(LucideIcons.messageSquare, size: 21),
      selectedIcon: Icon(LucideIcons.messageSquare, size: 23),
      label: 'Messages',
    ),
    NavigationDestination(
      icon: Icon(LucideIcons.package),
      label: 'Orders',
    ),
    NavigationDestination(
      icon: Icon(LucideIcons.users),
      label: 'Riders',
    ),
    NavigationDestination(
      icon: Icon(Icons.more_horiz),
      label: 'More',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: _navItems,
      ),
    );
  }
}
