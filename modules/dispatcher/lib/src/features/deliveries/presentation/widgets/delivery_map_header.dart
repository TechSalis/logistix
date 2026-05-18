import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared/shared.dart';

class DeliveryMapHeader extends StatelessWidget {
  const DeliveryMapHeader({required this.delivery, super.key});

  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final isRiderAssigned = delivery.rider != null;
    final hasRiderLocation = delivery.rider?.hasLocation ?? false;
    final isEnRoute = delivery.status == DeliveryStatus.EN_ROUTE;

    // Show rider location when rider is assigned and delivery is en route
    final shouldShowRiderLocation = isRiderAssigned && isEnRoute && hasRiderLocation;

    final displayLocation = shouldShowRiderLocation
        ? LatLng(delivery.rider!.lastLat!, delivery.rider!.lastLng!)
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
              _DeliveryTrackingMap(delivery: delivery, location: displayLocation)
            else
              _DeliveryPlaceholderHeader(delivery: delivery),
            
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

class _DeliveryTrackingMap extends StatelessWidget {
  const _DeliveryTrackingMap({required this.delivery, required this.location});
  final Delivery delivery;
  final LatLng location;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      key: ValueKey('map_${delivery.id}'),
      initialCameraPosition: CameraPosition(target: location, zoom: 15),
      markers: {
        Marker(
          markerId: const MarkerId('rider_with_delivery'),
          position: location,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: '${delivery.rider?.fullName ?? ''} - En Route',
            snippet: 'Delivering to ${delivery.dropOffAddress}',
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

class _DeliveryPlaceholderHeader extends StatelessWidget {
  const _DeliveryPlaceholderHeader({required this.delivery});
  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final isRiderAssigned = delivery.rider != null;
    final isEnRoute = delivery.status == DeliveryStatus.EN_ROUTE;

    return Container(
      width: double.infinity,
      color: LogistixColors.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: BootstrapSpacing.xxl),
          _AnimatedHeaderIcon(
            icon: isRiderAssigned && isEnRoute
                ? LucideIcons.locateFixed
                : isRiderAssigned ? LucideIcons.timer : LucideIcons.userPlus,
          ),
          const SizedBox(height: BootstrapSpacing.md),
          Text(
            !isRiderAssigned
                ? 'No Rider Assigned'
                : delivery.status == DeliveryStatus.ASSIGNED
                ? 'Waiting for Rider to Start'
                : isEnRoute ? 'Rider Location Unavailable' : 'Delivery ${delivery.status.label.capitalizeFirst()}',
            style: context.textTheme.labelLarge?.bold.copyWith(color: LogistixColors.textSecondary),
          ),
          const SizedBox(height: 2),
          Text(
            'Pickup: ${delivery.pickupAddress}',
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
