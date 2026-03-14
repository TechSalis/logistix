import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/bloc/rider_event.dart';
import 'package:rider/src/presentation/bloc/rider_state.dart';
import 'package:rider/src/presentation/pages/rider_locked_page.dart';

class RiderPage extends StatefulWidget {
  const RiderPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<RiderPage> createState() => _RiderPageState();
}

class _RiderPageState extends State<RiderPage> {
  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.map_outlined),
      activeIcon: Icon(Icons.map_rounded, color: LogistixColors.primary),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.list_alt_rounded),
      activeIcon: Icon(Icons.list_alt_rounded, color: LogistixColors.primary),
      label: 'Orders',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_outline_rounded),
      activeIcon: Icon(Icons.person_rounded, color: LogistixColors.primary),
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    context.read<RiderBloc>().add(const RiderEvent.fetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiderBloc, RiderState>(
      builder: (context, state) {
        return state.when(
          initial: () => const Scaffold(body: LogistixLoadingIndicator()),
          loading: () => const Scaffold(body: LogistixLoadingIndicator()),
          error: (message) => Scaffold(
            body: LogistixErrorView(
              message: message,
              onRetry: () => context.read<RiderBloc>().add(
                const RiderEvent.fetchProfile(),
              ),
            ),
          ),
          loaded: (rider, orders, isRefreshing, isOrdersLoading, loc) {
            if (!rider.isAccepted) {
              return RiderLockedPage(
                isRefreshing: isRefreshing,
                onRefresh: () => context.read<RiderBloc>().add(
                  const RiderEvent.refreshStatus(),
                ),
              );
            }

            return Scaffold(
              body: widget.navigationShell,
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
                  currentIndex: widget.navigationShell.currentIndex,
                  onTap: (index) {
                    widget.navigationShell.goBranch(
                      index,
                      initialLocation:
                          index == widget.navigationShell.currentIndex,
                    );
                  },
                  selectedItemColor: LogistixColors.primary,
                  unselectedItemColor: LogistixColors.textSecondary,
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  elevation: 0,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedLabelStyle: context.textTheme.labelMedium?.semiBold,
                  unselectedLabelStyle: context.textTheme.labelMedium?.medium,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
