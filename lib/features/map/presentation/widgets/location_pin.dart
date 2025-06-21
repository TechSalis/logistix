import 'package:flutter/material.dart';

class LocationPin extends StatelessWidget {
  const LocationPin({super.key, this.size = 40});

  final double size;
  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.location_on,
      size: size,
      color: Theme.of(context).colorScheme.secondary,
    );
  }
}
