import 'package:bootstrap/services/run_once.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:rider/src/domain/usecases/manage_rider_session_usecase.dart';
import 'package:rider/src/features/map/presentation/cubit/rider_map_orders_cubit.dart';
import 'package:rider/src/features/orders/presentation/cubit/rider_orders_cubit.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/bloc/rider_event.dart';
import 'package:rider/src/presentation/bloc/rider_state.dart';
import 'package:rider/src/presentation/pages/rider_locked_page.dart';
import 'package:shared/shared.dart';

class RiderPage extends StatefulWidget {
  const RiderPage({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  @override
  State<RiderPage> createState() => _RiderPageState();
}

class _RiderPageState extends State<RiderPage> {
  static const List<NavigationDestination> _navItems = [
    NavigationDestination(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.list_alt_rounded),
      selectedIcon: Icon(Icons.list_alt_rounded),
      label: 'Orders',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  late final riderBloc = context.read<RiderBloc>();
  RiderSessionManager? _sessionUseCase;

  @override
  void initState() {
    super.initState();
    riderBloc.add(RiderEvent.fetchProfile());
  }

  late final _startSessionIfNeeded = RunOnce.withArg((String riderId) {
    // Initialize cubits
    context.read<RiderOrdersCubit>().initialize();
    context.read<RiderMapOrdersCubit>().initialize();
    riderBloc.add(RiderEvent.observeProfile(riderId));

    // Start session
    _sessionUseCase = context.read<RiderSessionManager>()
      ..startSession();
  });

  @override
  void dispose() {
    _sessionUseCase?.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<RiderBloc, RiderState>(
            listener: (context, state) {
              state.whenOrNull(
                loading: (rider) {
                  if (rider != null && rider.permitStatus == PermitStatus.APPROVED) {
                    _startSessionIfNeeded(rider.id);
                  }
                },
                loaded: (rider, orders, isLoading, loc) {
                  if (rider.permitStatus == PermitStatus.APPROVED) {
                    _startSessionIfNeeded(rider.id);
                  }
                },
              );
            },
          ),
          BlocListener<MapCubit, MapState>(
            listener: (context, state) {
              state.whenOrNull(
                ready: (position) {
                  riderBloc.state.whenOrNull(
                    loaded: (rider, orders, isLoading, loc) {
                      if (rider.permitStatus == PermitStatus.APPROVED) {
                        _sessionUseCase?.startHeartbeat();
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
        child: BlocBuilder<RiderBloc, RiderState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox(),
              error: (message) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BootstrapErrorView(
                      message: message,
                      onRetry: () {
                        riderBloc.add(RiderEvent.fetchProfile());
                      },
                    ),
                    BootstrapButton(
                      label: 'Logout',
                      onPressed: riderBloc.logoutRunner.call,
                      type: BootstrapButtonType.danger,
                      icon: Icons.logout,
                    ),
                  ],
                );
              },
              loading: (rider) {
                if (rider != null && rider.permitStatus != PermitStatus.APPROVED) {
                  return RiderLockedPage(
                    onRefresh: () {
                      riderBloc.add(RiderEvent.fetchProfile());
                    },
                  );
                }

                return const Center(child: BootstrapInlineLoader());
              },
              loaded: (rider, orders, isLoading, loc) {
                if (rider.permitStatus != PermitStatus.APPROVED) {
                  return RiderLockedPage(
                    onRefresh: () {
                      riderBloc.add(RiderEvent.fetchProfile());
                    },
                  );
                }

                return widget.navigationShell;
              },
            );
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
        destinations: _navItems,
      ),
    );
  }
}
