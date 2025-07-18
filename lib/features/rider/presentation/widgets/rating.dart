
import 'package:flutter/material.dart';

class RatingGroupWidget extends StatelessWidget {
  const RatingGroupWidget({super.key, required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.star, size: 18, color: Colors.amber),
        Text(rating.toStringAsFixed(1)),
      ],
    );
  }
}