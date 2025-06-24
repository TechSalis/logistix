import 'package:flutter/material.dart';
import 'package:logistix/features/map/presentation/widgets/google_map_widget.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';
import 'package:logistix/features/rider/presentation/widgets/rider_card_small.dart';

class RiderTrackerDialog extends StatelessWidget {
  const RiderTrackerDialog({super.key, required this.rider});
  final Rider rider;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 120),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Expanded(child: MapViewWidget()),
              RiderCardSmall(rider: rider),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: Navigator.of(context).pop,
            ),
          ),
        ],
      ),
    );
  }
}
