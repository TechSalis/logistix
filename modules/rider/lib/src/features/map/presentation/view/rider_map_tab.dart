import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:rider/src/features/orders/presentation/cubit/rider_orders_cubit.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/bloc/rider_state.dart';
import 'package:rider/src/presentation/router/rider_routes.dart';
import 'package:shared/shared.dart';

class RiderMapTab extends StatefulWidget {
  const RiderMapTab({super.key});

  @override
  State<RiderMapTab> createState() => _RiderMapTabState();
}

class _RiderMapTabState extends State<RiderMapTab> {
  GoogleMapController? _mapController;
  Order? _selectedOrderOverlay;
  bool _isLocationSelected = false;

  void _animateToLocation(LatLng location, {double zoom = 16}) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: zoom),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Filter to show only assigned and en route orders on the map
    final ordersCubit = context.read<RiderOrdersCubit>();
    if (!ordersCubit.state.selectedStatuses.contains(OrderStatus.assigned)) {
      ordersCubit.filterByStatus([OrderStatus.assigned, OrderStatus.enRoute]);
    }
  }

  LatLng _mockCoordinateForOrder(String id, LatLng base, double offsetMulti) {
    // Generate a pseudo-random offset based on the order ID to keep it static
    final hash = id.hashCode;
    final latOffset = ((hash % 100) - 50) / 10000.0;
    final lngOffset = (((hash ~/ 100) % 100) - 50) / 10000.0;
    return LatLng(
      base.latitude + (latOffset * offsetMulti),
      base.longitude + (lngOffset * offsetMulti),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiderBloc, RiderState>(
      builder: (context, riderState) {
        final rider = riderState.mapOrNull(loaded: (state) => state.rider);

        final currentLocation = riderState.mapOrNull(
          loaded: (state) => state.location,
        );

        return BlocListener<RiderBloc, RiderState>(
          listenWhen: (previous, current) {
            final prevLoc = previous.mapOrNull(
              loaded: (state) => state.location,
            );
            final currLoc = current.mapOrNull(
              loaded: (state) => state.location,
            );
            return prevLoc != currLoc && currLoc != null;
          },
          listener: (context, state) {
            final loc = state.mapOrNull(loaded: (state) => state.location);
            if (loc != null) {
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(LatLng(loc.latitude, loc.longitude)),
              );
            }
          },
          child: BlocBuilder<RiderOrdersCubit, RiderOrdersState>(
            builder: (context, ordersState) {
              final activeOrders = ordersState.orders.where((o) {
                return o.status == OrderStatus.assigned ||
                    o.status == OrderStatus.enRoute;
              }).toList();

              final initialPos = currentLocation != null
                  ? LatLng(currentLocation.latitude, currentLocation.longitude)
                  : (rider?.hasLocation ?? false)
                  ? LatLng(rider!.lastLat!, rider.lastLng!)
                  : const LatLng(6.5244, 3.3792);

              final markers = <Marker>{};

              if (currentLocation != null || rider?.lastLat != null) {
                markers.add(
                  Marker(
                    markerId: const MarkerId('rider_location'),
                    position: initialPos,
                    onTap: () {
                      setState(() {
                        _selectedOrderOverlay = null;
                        _isLocationSelected = true;
                      });
                    },
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                  ),
                );
              }

              // Add mock markers for orders
              if (currentLocation != null) {
                for (final order in activeOrders) {
                  final isEnRoute = order.status == OrderStatus.enRoute;

                  final pickup = _mockCoordinateForOrder(
                    order.id,
                    initialPos,
                    0.5,
                  );
                  markers.add(
                    Marker(
                      markerId: MarkerId('${order.id}_pickup'),
                      position: pickup,
                      alpha: isEnRoute ? 1.0 : 0.6,
                      onTap: () {
                        setState(() {
                          _selectedOrderOverlay = order;
                          _isLocationSelected = false;
                        });
                      },
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange,
                      ),
                    ),
                  );

                  final dropoff = _mockCoordinateForOrder(
                    order.id,
                    initialPos,
                    1.5,
                  );
                  markers.add(
                    Marker(
                      markerId: MarkerId('${order.id}_dropoff'),
                      position: dropoff,
                      alpha: isEnRoute ? 1.0 : 0.6,
                      onTap: () {
                        setState(() {
                          _selectedOrderOverlay = order;
                          _isLocationSelected = false;
                        });
                      },
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                    ),
                  );
                }
              }

              return Scaffold(
                body: Stack(
                  children: [
                    Positioned.fill(
                      child: GoogleMap(
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        initialCameraPosition: CameraPosition(
                          target: initialPos,
                          zoom: 14,
                        ),
                        markers: markers,
                        onMapCreated: (c) => _mapController = c,
                      ),
                    ),

                    // Top Status Bar Area
                    Positioned(
                      top: MediaQuery.viewPaddingOf(context).top + 16,
                      left: 16,
                      right: 16,
                      child: _buildEnhancedTopStatus(
                        riderState.maybeMap(
                          loading: (_) => true,
                          orElse: () => false,
                        ),
                        rider,
                      ),
                    ),

                    // Upper Overlay for Selected Marker
                    if (_selectedOrderOverlay != null || _isLocationSelected)
                      Positioned(
                        top: MediaQuery.viewPaddingOf(context).top + 110,
                        left: 16,
                        right: 16,
                        child: Center(child: _buildMarkerOverlayCard()),
                      ),

                    // Enhanced Bottom Active Orders List
                    if (activeOrders.isNotEmpty)
                      DraggableScrollableSheet(
                        snap: true,
                        shouldCloseOnMinExtent: false,
                        minChildSize: 0.1,
                        maxChildSize: 0.8,
                        initialChildSize: 0.35,
                        snapSizes: const [0.1, 0.35, 0.8],
                        builder: (context, scrollController) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 16,
                                  offset: const Offset(0, -8),
                                ),
                              ],
                            ),
                            child: CustomScrollView(
                              controller: scrollController,
                              physics: const ClampingScrollPhysics(),
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 12),
                                      Container(
                                        width: 40,
                                        height: 5,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: LogistixColors.primary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.assignment_rounded,
                                                color: LogistixColors.primary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Active Orders',
                                              style: context
                                                  .textTheme
                                                  .titleMedium
                                                  ?.bold,
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: LogistixColors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '${activeOrders.length}',
                                                style: context
                                                    .textTheme
                                                    .labelMedium
                                                    ?.bold
                                                    .copyWith(
                                                      color: Colors.white,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    8,
                                    16,
                                    24,
                                  ),
                                  sliver: SliverList.separated(
                                    itemCount: activeOrders.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final order = activeOrders[index];
                                      return Stack(
                                        children: [
                                          OrderPreviewCard(
                                            order: order,
                                            onTap: () => context.push(
                                              RiderRoutes.orderDetails(
                                                order.id,
                                              ),
                                              extra: order,
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 16,
                                            right: 32,
                                            child: AnimatedScaleTap(
                                              onTap: () {
                                                final mockLocation =
                                                    _mockCoordinateForOrder(
                                                      order.id,
                                                      initialPos,
                                                      1,
                                                    );
                                                _animateToLocation(
                                                  mockLocation,
                                                );
                                                setState(() {
                                                  _selectedOrderOverlay = order;
                                                  _isLocationSelected = false;
                                                });
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: LogistixColors
                                                        .primary
                                                        .withValues(alpha: 0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.location_on_rounded,
                                                      size: 16,
                                                      color: LogistixColors
                                                          .primary,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'View',
                                                      style: context
                                                          .textTheme
                                                          .labelMedium
                                                          ?.copyWith(
                                                            color:
                                                                LogistixColors
                                                                    .primary,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEnhancedTopStatus(bool isLoading, Rider? rider) {
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const LogistixShimmer(
              width: 52,
              height: 52,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  LogistixShimmer(
                    width: 120,
                    height: 16,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 8),
                  LogistixShimmer(
                    width: 80,
                    height: 12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (rider == null) return const SizedBox.shrink();

    final isOnline = rider.status == RiderStatus.online;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  LogistixColors.primary,
                  LogistixColors.primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: LogistixColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rider.fullName,
                  style: context.textTheme.titleMedium?.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (isOnline)
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(seconds: 2),
                        builder: (context, value, child) {
                          return Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: LogistixColors.success,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: LogistixColors.success.withValues(
                                    alpha: value * 0.6,
                                  ),
                                  blurRadius: 4 + (value * 4),
                                  spreadRadius: value * 2,
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    const SizedBox(width: 6),
                    Text(
                      rider.status.name.toUpperCase(),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: isOnline
                            ? LogistixColors.success
                            : LogistixColors.textSecondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Navigate to rider location button
              if (rider.lastLat != null && rider.lastLng != null)
                AnimatedScaleTap(
                  onTap: () {
                    _animateToLocation(LatLng(rider.lastLat!, rider.lastLng!));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: LogistixColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.my_location_rounded,
                      size: 18,
                      color: LogistixColors.primary,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isOnline
                      ? LogistixColors.success.withValues(alpha: 0.1)
                      : LogistixColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isOnline
                        ? LogistixColors.success.withValues(alpha: 0.2)
                        : LogistixColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                      size: 16,
                      color: isOnline
                          ? LogistixColors.success
                          : LogistixColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      rider.status.label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: isOnline
                            ? LogistixColors.success
                            : LogistixColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarkerOverlayCard() {
    if (_isLocationSelected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: LogistixColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.my_location,
                color: LogistixColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            Text('My Location', style: context.textTheme.labelLarge?.bold),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _isLocationSelected = false),
              child: const Icon(
                Icons.close,
                size: 16,
                color: LogistixColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final order = _selectedOrderOverlay!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '#${order.trackingNumber}',
                maxLines: 1,
                style: context.textTheme.titleSmall?.bold,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => setState(() => _selectedOrderOverlay = null),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: LogistixColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedScaleTap(
            onTap: () {
              context.push(RiderRoutes.orderDetails(order.id), extra: order);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: LogistixColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.visibility_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'View Details',
                    style: context.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
