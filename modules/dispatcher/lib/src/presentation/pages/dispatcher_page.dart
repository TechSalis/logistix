import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// DispatcherPage acts as the Shell for the dispatcher module's tabs.
/// It uses a BottomNavigationBar with StatefulNavigationShell to preserve tab state.
class DispatcherPage extends StatelessWidget {
  const DispatcherPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<NavigationDestination> _navItems = [
    NavigationDestination(
      icon: Icon(Icons.list_alt_rounded),
      selectedIcon: Icon(Icons.list_alt_rounded),
      label: 'Orders',
    ),
    NavigationDestination(
      icon: Icon(Icons.message_outlined),
      selectedIcon: Icon(Icons.message),
      label: 'Messages',
    ),
    NavigationDestination(
      icon: Icon(Icons.people_outline_rounded),
      selectedIcon: Icon(Icons.people_rounded),
      label: 'Riders',
    ),
    NavigationDestination(
      icon: Icon(Icons.more_horiz_rounded),
      selectedIcon: Icon(Icons.more_horiz_rounded),
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
