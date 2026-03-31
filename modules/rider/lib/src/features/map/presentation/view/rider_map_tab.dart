import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:rider/src/features/map/presentation/cubit/rider_map_orders_cubit.dart';
import 'package:rider/src/features/map/presentation/widgets/rider_active_orders_sheet.dart';
import 'package:rider/src/features/map/presentation/widgets/rider_map_status_overlay.dart';
import 'package:rider/src/features/map/presentation/widgets/rider_marker_overlay_card.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/bloc/rider_state.dart';
import 'package:shared/shared.dart';

class RiderMapTab extends StatefulWidget {
  const RiderMapTab({super.key});

  @override
  State<RiderMapTab> createState() => _RiderMapTabState();
}

class _RiderMapTabState extends State<RiderMapTab>
    with SingleTickerProviderStateMixin {
  late final riderMapCubit = context.read<MapCubit>();

  GoogleMapController? _mapController;
  Order? _selectedOrderOverlay;
  bool _isLocationSelected = false;
  LatLng? _liveRiderLocation;

  StreamSubscription<Position>? _liveLocationSubscription;

  late AnimationController _sheetAnimationController;
  late Animation<double> _handleScaleAnimation;

  void _animateToLocation(LatLng location) {
    _mapController?.animateCamera(CameraUpdate.newLatLng(location));
  }

  @override
  void initState() {
    super.initState();

    _sheetAnimationController = AnimationController(
      vsync: this,
      duration: LogistixAnimations.normal,
    );

    _handleScaleAnimation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(
        parent: _sheetAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    riderMapCubit.requestLocationPermission();
  }

  @override
  void dispose() {
    _sheetAnimationController.dispose();
    _liveLocationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: BlocBuilder<MapCubit, MapState>(
          builder: (context, mapState) {
            return mapState.when(
              initial: () => const Center(child: LogistixInlineLoader()),
              checkingPermission: () {
                return const Center(child: LogistixInlineLoader());
              },
              permissionDenied: (message) => _PermissionDeniedView(
                message: message,
                onRetry: riderMapCubit.requestLocationPermission,
                onOpenSettings: riderMapCubit.openAppSettings,
              ),
              ready: (position) {
                _liveLocationSubscription ??=
                    Geolocator.getPositionStream(
                      locationSettings: const LocationSettings(
                        accuracy: LocationAccuracy.high,
                        distanceFilter: 5,
                      ),
                    ).listen((pos) {
                      if (mounted) {
                        setState(() {
                          _liveRiderLocation = LatLng(
                            pos.latitude,
                            pos.longitude,
                          );
                        });
                      }
                    });
                return _buildMapView(position);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMapView(Position initialPosition) {
    return BlocBuilder<RiderBloc, RiderState>(
      builder: (context, riderState) {
        final rider = riderState.mapOrNull(loaded: (state) => state.rider);

        return BlocBuilder<RiderMapOrdersCubit, RiderMapOrdersState>(
          builder: (context, ordersState) {
            if (ordersState.isLoading && ordersState.orders.isEmpty) {
              return const Center(child: LogistixInlineLoader());
            }

            if (ordersState.error != null && ordersState.orders.isEmpty) {
              return _ErrorView(message: ordersState.error!);
            }

            final activeOrders = ordersState.orders;
            final currentPos =
                _liveRiderLocation ??
                LatLng(initialPosition.latitude, initialPosition.longitude);

            final markers = _buildMarkers(currentPos, activeOrders);

            return Stack(
              children: [
                Positioned.fill(
                  bottom: 90,
                  child: GoogleMap(
                    style: LogistixMapTheme.cleanSlate,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        initialPosition.latitude,
                        initialPosition.longitude,
                      ),
                      zoom: 15,
                    ),
                    markers: markers,
                    onMapCreated: (c) => _mapController = c,
                  ),
                ),

                if (_selectedOrderOverlay != null || _isLocationSelected)
                  Positioned(
                    top: MediaQuery.viewPaddingOf(context).top + 110,
                    left: LogistixSpacing.lg,
                    right: LogistixSpacing.lg,
                    child: Center(
                      child: RiderMarkerOverlayCard(
                        isLocationSelected: _isLocationSelected,
                        selectedOrder: _selectedOrderOverlay,
                      ),
                    ),
                  ),

                RiderActiveOrdersSheet(
                  activeOrders: activeOrders,
                  sheetAnimationController: _sheetAnimationController,
                  handleScaleAnimation: _handleScaleAnimation,
                  onAnimateToLocation: _animateToLocation,
                  onLocationSelectedChanged: (val) {
                    setState(() => _isLocationSelected = val);
                  },
                ),

                Positioned(
                  left: LogistixSpacing.lg,
                  right: LogistixSpacing.lg,
                  child: SafeArea(
                    child: RiderMapStatusOverlay(
                      isLoading: ordersState.isLoading,
                      rider: rider,
                      liveRiderLocation: _liveRiderLocation,
                      onAnimateToLocation: _animateToLocation,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Set<Marker> _buildMarkers(LatLng currentPos, List<Order> orders) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('rider_live_location'),
        position: currentPos,
        zIndexInt: 2,
        onTap: () {
          setState(() {
            _selectedOrderOverlay = null;
            _isLocationSelected = true;
          });
        },
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };

    for (final order in orders) {
      final isEnRoute = order.status == OrderStatus.EN_ROUTE;

      if (order.pickupLat != null && order.pickupLng != null) {
        markers.add(
          Marker(
            markerId: MarkerId('${order.id}_pickup'),
            position: LatLng(order.pickupLat!, order.pickupLng!),
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
      }

      if (isEnRoute && order.dropOffLat != null && order.dropOffLng != null) {
        markers.add(
          Marker(
            markerId: MarkerId('${order.id}_dropoff'),
            position: LatLng(order.dropOffLat!, order.dropOffLng!),
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
    return markers;
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LogistixEntrance(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: LogistixColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: LogistixColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Orders',
              style: context.textTheme.headlineSmall?.bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: LogistixColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  const _PermissionDeniedView({
    required this.message,
    required this.onRetry,
    required this.onOpenSettings,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: LogistixEntrance(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: LogistixColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 48,
                color: LogistixColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Location Required',
              style: context.textTheme.headlineSmall?.bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: context.textTheme.bodyMedium?.copyWith(
                color: LogistixColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            LogistixButton(
              onPressed: onRetry,
              label: 'TRY AGAIN',
              icon: Icons.refresh_rounded,
            ),
            const SizedBox(height: 12),
            LogistixButton(
              onPressed: onOpenSettings,
              label: 'OPEN SETTINGS',
              type: LogistixButtonType.outline,
              icon: Icons.settings_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
