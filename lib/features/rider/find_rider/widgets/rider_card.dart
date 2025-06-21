
import 'package:flutter/material.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';

class RiderCard extends StatelessWidget {
  const RiderCard({super.key, required this.rider, this.eta});

  final Rider rider;
  final String? eta;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          child: Text(
            rider.name[0],
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rider.name, style: Theme.of(context).textTheme.titleMedium),
              if (rider.company != null)
                Text(
                  rider.company!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              Row(
                children: [
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  Text(" ${rider.rating}"),
                  const Spacer(),
                  const Icon(Icons.timer_outlined, size: 16),
                  Text(" $eta"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
