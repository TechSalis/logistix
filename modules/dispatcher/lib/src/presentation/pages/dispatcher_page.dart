import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';

/// DispatcherPage acts as the Shell for the dispatcher module's tabs.
/// It uses a BottomNavigationBar with StatefulNavigationShell to preserve tab state.
class DispatcherPage extends StatelessWidget {
  const DispatcherPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.list_alt_rounded),
      activeIcon: Icon(Icons.list_alt_rounded, color: LogistixColors.primary),
      label: 'Orders',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.people_outline_rounded),
      activeIcon: Icon(Icons.people_rounded, color: LogistixColors.primary),
      label: 'Riders',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.more_horiz_rounded),
      activeIcon: Icon(Icons.more_horiz_rounded, color: LogistixColors.primary),
      label: 'More',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: _navItems,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          selectedItemColor: LogistixColors.primary,
          unselectedItemColor: LogistixColors.textSecondary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: context.textTheme.labelMedium?.semiBold,
          unselectedLabelStyle: context.textTheme.labelMedium?.medium,
        ),
      ),
    );
  }
}
