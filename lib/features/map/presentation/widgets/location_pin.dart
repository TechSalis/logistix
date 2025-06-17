import 'package:flutter/material.dart';
import 'package:logistix/core/constants/colors.dart';

class LocationPin extends StatelessWidget {
  const LocationPin({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(Icons.location_on, size: 40, color: AppColors.locationPin),
    );
  }
}
