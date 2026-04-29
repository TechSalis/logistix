import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class OrderMapHeader extends StatelessWidget {
  const OrderMapHeader({required this.order, super.key});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final isRiderAssigned = order.rider != null;
    final hasRiderLocation = order.rider?.hasLocation ?? false;
    final isEnRoute = order.status == OrderStatus.EN_ROUTE;

    // Show rider location when rider is assigned and order is en route
    final shouldShowRiderLocation = isRiderAssigned && isEnRoute && hasRiderLocation;

    final displayLocation = shouldShowRiderLocation
        ? LatLng(order.rider!.lastLat!, order.rider!.lastLng!)
        : null;

    final expandedHeight = displayLocation != null ? 260.0 : 140.0;

    return SliverAppBar(
      pinned: true,
      stretch: true,
      elevation: 0,
      expandedHeight: expandedHeight,
      backgroundColor: LogistixColors.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            if (displayLocation != null)
              _OrderTrackingMap(order: order, location: displayLocation)
            else
              _OrderPlaceholderHeader(order: order),
            
            // Gradient Overlay
            _HeaderGradient(),
            
            if (shouldShowRiderLocation)
              const _LiveTrackingBadge(),
          ],
        ),
      ),
    );
  }
}

class _OrderTrackingMap extends StatelessWidget {
  const _OrderTrackingMap({required this.order, required this.location});
  final Order order;
  final LatLng location;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      key: ValueKey('map_${order.id}'),
      initialCameraPosition: CameraPosition(target: location, zoom: 15),
      markers: {
        Marker(
          markerId: const MarkerId('rider_with_order'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: '${order.rider?.fullName ?? ''} - En Route',
            snippet: 'Delivering to ${order.dropOffAddress}',
          ),
        ),
      },
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      style: LogistixMapTheme.cleanSlate,
    );
  }
}

class _OrderPlaceholderHeader extends StatelessWidget {
  const _OrderPlaceholderHeader({required this.order});
  final Order order;

  @override
  Widget build(BuildContext context) {
    final isRiderAssigned = order.rider != null;
    final isEnRoute = order.status == OrderStatus.EN_ROUTE;

    return Container(
      width: double.infinity,
      color: LogistixColors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: BootstrapSpacing.xxl),
          _AnimatedHeaderIcon(
            icon: isRiderAssigned && isEnRoute
                ? Icons.location_searching_rounded
                : isRiderAssigned ? Icons.timer_outlined : Icons.person_add_outlined,
          ),
          const SizedBox(height: BootstrapSpacing.md),
          Text(
            !isRiderAssigned
                ? 'No Rider Assigned'
                : order.status == OrderStatus.ASSIGNED
                ? 'Waiting for Rider to Start'
                : isEnRoute ? 'Rider Location Unavailable' : 'Order ${order.status.label.capitalizeFirst()}',
            style: context.textTheme.labelLarge?.bold.copyWith(color: LogistixColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            'Pickup: ${order.pickupAddress}',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textTheme.bodySmall?.copyWith(color: LogistixColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _AnimatedHeaderIcon extends StatelessWidget {
  const _AnimatedHeaderIcon({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(BootstrapSpacing.md),
      decoration: BoxDecoration(
        color: LogistixColors.primary.withValues(alpha: 0.05),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 32, color: LogistixColors.textTertiary),
    );
  }
}

class _HeaderGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.2),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveTrackingBadge extends StatelessWidget {
  const _LiveTrackingBadge();
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 60,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(BootstrapRadii.xl),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(width: BootstrapSpacing.xs),
            Text('Live Tracking', style: context.textTheme.labelSmall?.bold.copyWith(color: Colors.white, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}
