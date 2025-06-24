import 'package:flutter/material.dart';

class OrderFareWidget extends StatelessWidget {
  const OrderFareWidget({
    super.key,
    required this.farePrice,
    this.eta,
    this.color,
  });

  final String farePrice;
  final String? eta;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color ?? Theme.of(context).highlightColor,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          DefaultTextStyle(
            style: Theme.of(
              context,
            ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('Estimated Fare'), Text(farePrice)],
            ),
          ),
          if (eta != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium!,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Based on distance and time'),
                    Text(eta!),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
