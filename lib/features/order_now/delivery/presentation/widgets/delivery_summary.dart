import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';

class DeliverySummaryDialog extends StatelessWidget {
  final Address pickup;
  final Address dropoff;
  final String note;

  const DeliverySummaryDialog({
    super.key,
    required this.pickup,
    required this.dropoff,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 52, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              "Delivery Summary",
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Pickup Map + Info
            _MapLocationCard(
              label: "Pickup",
              address: pickup.formatted,
              // coordinates: pickup.coordinates,
            ),

            const SizedBox(height: 16),

            // Drop-off Map + Info
            _MapLocationCard(
              label: "Drop-off",
              address: dropoff.formatted,
              // coordinates: dropoff.coordinates,
            ),

            const SizedBox(height: 16),
            _SummaryRow(label: "Note", value: note),
            const SizedBox(height: 12),

            // _SummaryRow(label: "ETA", value: eta),
            // _SummaryRow(label: "Estimated Price", value: price),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: GoRouter.of(context).pop,
                icon: const Icon(Icons.motorcycle),
                label: const Text("Call Rider"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ),
      ],
    );
  }
}

class _MapLocationCard extends StatelessWidget {
  final String label;
  final String address;

  const _MapLocationCard({required this.label, required this.address});

  @override
  Widget build(BuildContext context) {
    // final imageUrl = coordinates != null
    //     ? "https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/"
    //         "${coordinates!.longitude},${coordinates!.latitude},15,0/300x150?access_token=YOUR_MAPBOX_TOKEN"
    //     : null;

    return Card(
      elevation: 2,
      color: Theme.of(context).inputDecorationTheme.fillColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (imageUrl != null)
          //   Image.network(
          //     imageUrl,
          //     width: double.infinity,
          //     height: 150,
          //     fit: BoxFit.cover,
          //     errorBuilder: (_, __, ___) => Container(
          //       height: 150,
          //       color: Colors.grey[300],
          //       alignment: Alignment.center,
          //       child: const Text("Map preview unavailable"),
          //     ),
          //   ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: _SummaryRow(label: label, value: address),
          ),
        ],
      ),
    );
  }
}
