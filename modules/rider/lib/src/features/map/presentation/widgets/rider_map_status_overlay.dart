import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

class RiderMapStatusOverlay extends StatelessWidget {
  const RiderMapStatusOverlay({
    required this.isLoading,
    required this.rider,
    required this.liveRiderLocation,
    required this.onAnimateToLocation,
    super.key,
  });

  final bool isLoading;
  final Rider? rider;
  final LatLng? liveRiderLocation;
  final ValueChanged<LatLng> onAnimateToLocation;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _StatusContainer(
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

    return _StatusContainer(
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
                  rider!.fullName,
                  style: context.textTheme.titleMedium?.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: rider!.status.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: rider!.status.color,
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rider!.status.label,
                      style: context.textTheme.labelSmall?.copyWith(
                        color: rider!.status.color,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (liveRiderLocation != null || rider!.hasLocation)
            AnimatedScaleTap(
              onTap: () {
                final loc = liveRiderLocation ??
                    LatLng(rider!.lastLat!, rider!.lastLng!);
                onAnimateToLocation(loc);
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
        ],
      ),
    );
  }
}

class _StatusContainer extends StatelessWidget {
  const _StatusContainer({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
      child: child,
    );
  }
}
