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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return LogistixTextField(
      label: '',
      onChanged: onChanged,
      hintText: 'Search riders...',
      icon: Icons.search_rounded,
    );
  }
}

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
          padding: const EdgeInsets.symmetric(horizontal: LogistixSpacing.lg),
          child: Row(
            children: [
              _StatusChip(
                label: 'All',
                isSelected: state.selectedStatus == null,
                onTap: () => ridersCubit.filterByStatus(null),
              ),
              ...allStatuses.map((status) {
                final isSelected = state.selectedStatus == status;
                return _StatusChip(
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? LogistixColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? LogistixColors.primary
                : LogistixColors.border.withValues(alpha: 0.5),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: LogistixColors.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Text(
          label,
          style: context.textTheme.labelSmall?.bold.copyWith(
            color: isSelected ? Colors.white : LogistixColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
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
                        colors: [LogistixColors.primary, Color(0xFF4F46E5)],
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
                      padding: EdgeInsets.only(bottom: 24),
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
              padding: const EdgeInsets.symmetric(vertical: LogistixSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LogistixSpacing.lg,
                    ),
                    child: Hero(
                      tag: 'rider-search-tag',
                      child: Row(
                        children: [
                          Expanded(
                            child: _SearchField(
                              onChanged: ridersCubit.searchRiders,
                            ),
                          ),
                          const SizedBox(width: 12),
                          AnimatedScaleTap(
                            onTap: () => context.go(DispatcherRoutes.ridersMap),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
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
                  const SizedBox(height: 16),
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
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: LogistixShimmer(
                          width: double.infinity,
                          height: 120,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      );
                    }, childCount: 5),
                  ),
                );
              }

              if (state.error != null && state.riders.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: LogistixErrorView(message: state.error!),
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
                        const SizedBox(height: 16),
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
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Text(
                          'Pending Approval (${filteredPending.length})',
                          style: context.textTheme.labelSmall?.bold.copyWith(
                            color: LogistixColors.warning,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...filteredPending.mapIndexed(
                        (idx, rider) => LogistixEntrance(
                          delay: Duration(milliseconds: idx * 50),
                          children: [RiderCard(rider: rider, isPending: true)],
                        ),
                      ),
                    ],
                    if (filteredActive.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Text(
                          'Active Riders (${filteredActive.length})',
                          style: context.textTheme.labelSmall?.bold.copyWith(
                            color: LogistixColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ...filteredActive.mapIndexed(
                        (idx, rider) => LogistixEntrance(
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

  void _focusRider(String riderId) => ridersCubit.selectRider(riderId);

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
                          ridersCubit.selectRider(r.id);
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
                    left: 16,
                    right: 16,
                    bottom: 32,
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
                                      ridersCubit.selectRider(r.id);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              AnimatedScaleTap(
                                onTap: () =>
                                    context.go(DispatcherRoutes.ridersList),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
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
