import 'package:bootstrap/services/equality_filter.dart';
import 'package:collection/collection.dart';

import 'package:dispatcher/src/features/riders/presentation/cubit/riders_cubit.dart';
import 'package:dispatcher/src/features/riders/presentation/widgets/rider_card.dart';
import 'package:dispatcher/src/presentation/router/dispatcher_routes.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class RidersTab extends StatefulWidget {
  const RidersTab({super.key});

  @override
  State<RidersTab> createState() => _RidersTabState();
}

class _RidersTabState extends State<RidersTab> {
  bool _isMapView = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndLoadData(_isMapView);
    });
  }

  void _onToggleView() {
    setState(() => _isMapView = !_isMapView);
    _checkAndLoadData(_isMapView);
  }

  void _checkAndLoadData(bool isMapView) {
    final cubit = context.read<RidersCubit>();
    if (isMapView) {
      if (cubit.state.mapRiders.isEmpty && !cubit.state.isLoading) {
        cubit.loadMapRiders();
      }
    } else {
      if ((cubit.state.riders.isEmpty || cubit.state.pendingRiders.isEmpty) &&
          !cubit.state.isLoading) {
        cubit.loadAll();
      }
    }
  }

  void _selectRiderOnMap(RiderLocationInfo? rider) {
    if (rider != null) {
      if (rider.hasLocation) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(rider.lastLat!, rider.lastLng!),
            15,
          ),
        );
      } else {
        // Show snackbar that rider has no location
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${rider.fullName} has no active location.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openRiderDetails(Rider rider) async {
    final result = await context.push(DispatcherRoutes.riderDetails(rider.id));
    if (result is Rider) {
      // "View on Map" was pressed
      if (!_isMapView) {
        setState(() => _isMapView = true);
      }

      _selectRiderOnMap(result.toLocationInfo());
    }
  }

  @override
  Widget build(BuildContext context) {
    final ridersCubit = context.read<RidersCubit>();

    return BlocBuilder<RidersCubit, RidersState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: LogistixColors.background,
          body: _isMapView
              ? _RidersMapView(
                  state: state,
                  onRiderSelected: _selectRiderOnMap,
                  onToggleView: _onToggleView,
                  onSearchRiders: ridersCubit.searchMapRiders,
                  onMapCreated: (c) => _mapController = c,
                )
              : _RidersListView(
                  state: state,
                  onToggleView: _onToggleView,
                  onRefresh: ridersCubit.loadAll,
                  onSearchChanged: ridersCubit.searchRiders,
                  onRiderTapped: _openRiderDetails,
                ),
        );
      },
    );
  }
}

class _RidersListView extends StatelessWidget {
  const _RidersListView({
    required this.state,
    required this.onToggleView,
    required this.onRefresh,
    required this.onSearchChanged,
    required this.onRiderTapped,
  });

  final RidersState state;
  final VoidCallback onToggleView;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Rider> onRiderTapped;

  @override
  Widget build(BuildContext context) {
    final filteredActive = state.filteredRiders;
    final filteredPending = state.filteredPendingRiders;
    final hasSearch = state.searchQuery.isNotEmpty;
    final isEmpty = filteredActive.isEmpty && filteredPending.isEmpty;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverSafeArea(
            bottom: false,
            sliver: SliverAppBar(
              toolbarHeight: 80,
              floating: true,
              backgroundColor: LogistixColors.background,
              title: TextField(
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search riders...',
                  hintStyle: context.textTheme.bodyMedium?.copyWith(
                    color: LogistixColors.textTertiary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: LogistixColors.primary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: onToggleView,
                  icon: const Icon(
                    Icons.map_rounded,
                    color: LogistixColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          if (state.isLoading &&
              state.riders.isEmpty &&
              state.pendingRiders.isEmpty)
            _buildLoadingState()
          else if (state.error != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: LogistixErrorView(
                message: state.error!,
                onRetry: onRefresh,
              ),
            )
          else if (isEmpty)
            _buildEmptyState(context, hasSearch)
          else ...[
            if (filteredPending.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Pending Approval (${filteredPending.length})',
                    style: context.textTheme.titleSmall?.bold.copyWith(
                      color: LogistixColors.warning,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final rider = filteredPending[index];
                  return AnimatedScaleTap(
                    onTap: () => onRiderTapped(rider),
                    child: SlideFadeTransition(
                      child: RiderCard(rider: rider, isPending: true),
                    ),
                  );
                }, childCount: filteredPending.length),
              ),
            ],
            if (filteredActive.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Active Riders (${filteredActive.length})',
                    style: context.textTheme.titleSmall?.bold,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final rider = filteredActive[index];
                  return AnimatedScaleTap(
                    onTap: () => onRiderTapped(rider),
                    child: SlideFadeTransition(
                      child: RiderCard(rider: rider, isPending: false),
                    ),
                  );
                }, childCount: filteredActive.length),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LogistixShimmer(
              width: double.infinity,
              height: 100,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }, childCount: 5),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool hasSearch) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch
                  ? Icons.search_off_rounded
                  : Icons.directions_bike_rounded,
              size: 64,
              color: LogistixColors.textTertiary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              hasSearch ? 'No riders matching your search' : 'No riders found',
              style: context.textTheme.bodyLarge?.copyWith(
                color: LogistixColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RidersMapView extends StatelessWidget {
  const _RidersMapView({
    required this.state,
    required this.onRiderSelected,
    required this.onToggleView,
    required this.onMapCreated,
    required this.onSearchRiders,
  });

  final RidersState state;
  final ValueChanged<RiderLocationInfo?> onRiderSelected;
  final VoidCallback onToggleView;
  final ValueChanged<GoogleMapController> onMapCreated;
  final Future<List<Rider>> Function(String) onSearchRiders;

  @override
  Widget build(BuildContext context) {
    final ridersWithLocation = state.mapRiders
        .where((r) => r.hasLocation)
        .toList();

    var initialPos = const LatLng(6.5244, 3.3792);
    if (ridersWithLocation.isNotEmpty) {
      final avgLat = ridersWithLocation.map((r) => r.lastLat!).average;
      final avgLng = ridersWithLocation.map((r) => r.lastLng!).average;
      initialPos = LatLng(avgLat, avgLng);
    }

    final topPadding = MediaQuery.viewPaddingOf(context).top;

    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: LogistixColors.surfaceDim,
            child: GoogleMap(
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                target: initialPos,
                zoom: 12,
              ),
              onMapCreated: onMapCreated,
              markers: ridersWithLocation.map((r) {
                return Marker(
                  markerId: MarkerId(r.id),
                  position: LatLng(r.lastLat!, r.lastLng!),
                  infoWindow: InfoWindow(title: r.fullName),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                  onTap: () => onRiderSelected(r),
                );
              }).toSet(),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.fromLTRB(16, topPadding + 16, 8, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownSearch<Rider>(
                    items: (String filter, _) => onSearchRiders(filter),
                    compareFn: EqualityFilter<Rider>((state) => state.id).call,
                    onChanged: (rider) {
                      return onRiderSelected(rider?.toLocationInfo());
                    },
                    suffixProps: const DropdownSuffixProps(
                      clearButtonProps: ClearButtonProps(isVisible: true),
                      dropdownButtonProps: DropdownButtonProps(
                        isVisible: false,
                      ),
                    ),
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      loadingBuilder: (_, _) {
                        return const LogistixLoadingIndicator();
                      },
                      searchFieldProps: TextFieldProps(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search rider...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                      ),
                      itemBuilder: (context, rider, isDisabled, isSelected) {
                        return RiderInfoListTile(
                          rider: rider,
                          enabled: rider.hasLocation,
                          isSelected: isSelected,
                        );
                      },
                    ),
                    decoratorProps: DropDownDecoratorProps(
                      decoration: InputDecoration(
                        hintText: 'Search rider on map...',
                        hintStyle: context.textTheme.bodyMedium?.copyWith(
                          color: LogistixColors.textTertiary,
                        ),
                        prefixIcon: const Icon(
                          Icons.location_pin,
                          color: LogistixColors.primary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    dropdownBuilder: (context, selectedItem) {
                      if (selectedItem == null) {
                        return Text(
                          'Search rider on map...',
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: LogistixColors.textTertiary,
                          ),
                        );
                      }
                      return Text(
                        selectedItem.fullName,
                        style: context.textTheme.bodyMedium?.bold.copyWith(
                          color: selectedItem.hasLocation
                              ? null
                              : LogistixColors.textTertiary,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: onToggleView,
                  icon: const Icon(
                    Icons.list_rounded,
                    color: LogistixColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

extension on Rider {
  RiderLocationInfo toLocationInfo() {
    return RiderLocationInfo(
      id: id,
      fullName: fullName,
      lastLat: lastLng,
      lastLng: lastLng,
    );
  }
}
