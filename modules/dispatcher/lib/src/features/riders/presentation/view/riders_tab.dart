import 'package:bootstrap/services/equality_filter.dart';
import 'package:collection/collection.dart';
import 'package:dispatcher/src/domain/usecases/search_riders_usecase.dart';
import 'package:dispatcher/src/features/riders/presentation/cubit/riders_cubit.dart';
import 'package:dispatcher/src/features/riders/presentation/utils/rider_map_utils.dart';
import 'package:dispatcher/src/features/riders/presentation/widgets/rider_card.dart';
import 'package:dispatcher/src/features/riders/presentation/widgets/rider_dropdown_search.dart';
import 'package:dispatcher/src/features/riders/presentation/widgets/rider_summary_card.dart';
import 'package:dispatcher/src/presentation/router/dispatcher_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';


class _RiderStatusFilterList extends StatelessWidget {
  const _RiderStatusFilterList();

  @override
  Widget build(BuildContext context) {
    final ridersCubit = context.read<RidersCubit>();
    return BlocBuilder<RidersCubit, RidersState>(
      builder: (context, state) {
        const allStatuses = RiderStatus.values;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: BootstrapSpacing.lg),
          child: Row(
            children: [
              BootstrapChoiceChip(
                label: 'All',
                isSelected: state.selectedStatus == null,
                onTap: () => ridersCubit.filterByStatus(null),
              ),
              ...allStatuses.map((status) {
                final isSelected = state.selectedStatus == status;
                return BootstrapChoiceChip(
                  label: status.label,
                  isSelected: isSelected,
                  onTap: () => ridersCubit.filterByStatus(status),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}


class RidersListView extends StatelessWidget {
  const RidersListView({super.key});

  @override
  Widget build(BuildContext context) {
    final ridersCubit = context.read<RidersCubit>();

    return Scaffold(
      backgroundColor: LogistixColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            toolbarHeight: 0,
            collapsedHeight: 0,
            expandedHeight: 160,
            backgroundColor: LogistixColors.primary,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.fadeTitle,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          LogistixColors.primary,
                          LogistixColors.secondaryDark,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: BootstrapSpacing.lg),
                      child: RiderSummaryCard(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          PinnedHeaderSliver(
            child: Container(
              color: LogistixColors.background,
              padding: const EdgeInsets.symmetric(
                vertical: BootstrapSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BootstrapSpacing.lg,
                    ),
                    child: Hero(
                      tag: 'rider-search-tag',
                      child: Row(
                        children: [
                          Expanded(
                            child: BootstrapSearchField(
                              onChanged: ridersCubit.searchRiders,
                              hintText: 'Search riders...',
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedScaleTap(
                            onTap: () => context.go(DispatcherRoutes.ridersMap),
                            child: Container(
                              padding: const EdgeInsets.all(
                                BootstrapSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  BootstrapRadii.xl,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.map_rounded,
                                color: LogistixColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: BootstrapSpacing.md),
                  const _RiderStatusFilterList(),
                ],
              ),
            ),
          ),
          BlocBuilder<RidersCubit, RidersState>(
            builder: (context, state) {
              final filteredActive = state.filteredRiders;
              final filteredPending = state.filteredPendingRiders;
              final isEmpty = filteredActive.isEmpty && filteredPending.isEmpty;

              if (state.isLoading &&
                  state.riders.isEmpty &&
                  state.pendingRiders.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.all(BootstrapSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: BootstrapSpacing.md,
                        ),
                        child: BootstrapShimmer(
                          width: double.infinity,
                          height: 120,
                          borderRadius: BorderRadius.circular(
                            BootstrapRadii.xxl,
                          ),
                        ),
                      );
                    }, childCount: 5),
                  ),
                );
              }

              if (state.error != null && state.riders.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: BootstrapErrorView(message: state.error!),
                );
              }

              if (isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          state.searchQuery.isNotEmpty
                              ? Icons.search_off_rounded
                              : Icons.directions_bike_rounded,
                          size: 64,
                          color: LogistixColors.textTertiary.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: BootstrapSpacing.md),
                        Text(
                          state.searchQuery.isNotEmpty
                              ? 'No riders matching your search'
                              : 'No riders found',
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: LogistixColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (filteredPending.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          BootstrapSpacing.lg,
                          BootstrapSpacing.md,
                          BootstrapSpacing.lg,
                          BootstrapSpacing.xs,
                        ),
                        child: Text(
                          'Pending Approval (${filteredPending.length})',
                          style: context.textTheme.labelSmall?.bold.copyWith(
                            color: LogistixColors.warning,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...filteredPending.mapIndexed(
                        (idx, rider) => BootstrapEntrance(
                          delay: Duration(milliseconds: idx * 50),
                          children: [RiderCard(rider: rider, isPending: true)],
                        ),
                      ),
                    ],
                    if (filteredActive.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          BootstrapSpacing.lg,
                          BootstrapSpacing.md,
                          BootstrapSpacing.lg,
                          BootstrapSpacing.xs,
                        ),
                        child: Text(
                          'Active Riders (${filteredActive.length})',
                          style: context.textTheme.labelSmall?.bold.copyWith(
                            color: LogistixColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...filteredActive.mapIndexed(
                        (idx, rider) => BootstrapEntrance(
                          delay: Duration(
                            milliseconds: (filteredPending.length + idx) * 50,
                          ),
                          children: [RiderCard(rider: rider, isPending: false)],
                        ),
                      ),
                    ],
                  ]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class RidersMapView extends StatefulWidget {
  const RidersMapView({super.key, this.riderId});

  final String? riderId;

  @override
  State<RidersMapView> createState() => _RidersMapViewState();
}

class _RidersMapViewState extends State<RidersMapView> {
  late final ridersCubit = context.read<RidersCubit>();
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    context.read<MapCubit>().requestLocationPermission();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    if (widget.riderId != null) {
      _focusRider(widget.riderId!);
    }
  }

  void _focusRider(String riderId) => ridersCubit.selectRiderById(riderId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: BlocConsumer<RidersCubit, RidersState>(
          listenWhen: EqualityFilter<RidersState>(
            (state) => state.selectedRider?.id,
          ).call,
          listener: (context, state) {
            final rider = state.selectedRider;
            if (rider != null && rider.hasLocation) {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(
                  LatLng(rider.lastLat!, rider.lastLng!),
                  15,
                ),
              );
            }
          },
          builder: (context, state) {
            var initialPos = const LatLng(6.5244, 3.3792);

            final ridersWithLocation = state.mapRiders
                .where((r) => r.hasLocation)
                .toList();

            if (ridersWithLocation.isNotEmpty) {
              final avgLat = ridersWithLocation.map((r) => r.lastLat!).average;
              final avgLng = ridersWithLocation.map((r) => r.lastLng!).average;
              initialPos = LatLng(avgLat, avgLng);
            }

            return Stack(
              children: [
                Positioned.fill(
                  child: GoogleMap(
                    style: LogistixMapTheme.cleanSlate,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: initialPos,
                      zoom: 15,
                    ),
                    onMapCreated: _onMapCreated,
                    onTap: (_) {
                      FocusScope.of(context).unfocus();
                      ridersCubit.selectRider(null);
                    },
                    markers: ridersWithLocation.mapIndexed((i, r) {
                      return Marker(
                        zIndexInt: r.id == state.selectedRider?.id ? 100000 : i,
                        markerId: MarkerId(r.id),
                        position: LatLng(r.lastLat!, r.lastLng!),
                        onTap: () {
                          ridersCubit.selectRiderById(r.id);
                        },
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          RiderMapUtils.getHue(r.id),
                        ),
                      );
                    }).toSet(),
                  ),
                ),
                if (state.selectedRider != null)
                  Positioned(
                    left: BootstrapSpacing.md,
                    right: BootstrapSpacing.md,
                    bottom: BootstrapSpacing.xl,
                    child: Center(
                      child: RiderMapInfoCard(
                        rider: state.selectedRider!,
                        onClose: () => ridersCubit.selectRider(null),
                        onTap: () => context.push(
                          DispatcherRoutes.riderDetails(
                            state.selectedRider!.id,
                          ),
                        ),
                      ),
                    ),
                  ),
                // Search and Overlays
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        Hero(
                          tag: 'rider-search-tag',
                          child: Row(
                            children: [
                              Expanded(
                                child: _MapSearchOverlay(
                                  onRiderSelected: (r) {
                                    if (r != null) {
                                      ridersCubit.selectRider(r);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              AnimatedScaleTap(
                                onTap: () =>
                                    context.go(DispatcherRoutes.ridersList),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    BootstrapSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                      BootstrapRadii.xl,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.list_rounded,
                                    color: LogistixColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MapSearchOverlay extends StatelessWidget {
  const _MapSearchOverlay({required this.onRiderSelected});

  final ValueChanged<Rider?> onRiderSelected;

  @override
  Widget build(BuildContext context) {
    return RiderDropdownSearch(
      selectedRider: null,
      searchRiders: (filter) =>
          context.read<SearchRidersUseCase>().call(filter),
      onChanged: onRiderSelected,
      label: 'Search rider on map...',
    );
  }
}
