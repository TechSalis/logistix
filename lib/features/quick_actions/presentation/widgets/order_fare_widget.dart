import 'package:flutter/material.dart';

class OrderFareWidget extends StatelessWidget {
  const OrderFareWidget({
    super.key,
    required this.color,
    required this.farePrice,
    required this.eta,
  });

  final Color color;
  final String farePrice, eta;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          DefaultTextStyle(
            style: Theme.of(
              context,
            ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text('Estimated Fare'), Text(farePrice)],
            ),
          ),
          SizedBox(height: 8),
          DefaultTextStyle(
            style: Theme.of(context).textTheme.bodyMedium!,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Based on distance and time'),
                Text(eta),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
