import 'dart:math';

import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/core/entities/rider_data.dart';

abstract class RiderRepo {
  Stream<Coordinates> listenToRiderCoordinates(RiderData rider) {
    double lat = Random().nextInt(180) - 90, long = Random().nextInt(360) - 180;
    return Stream.periodic(const Duration(seconds: 5), (computationCount) {
      return Coordinates(
        lat + (Random().nextInt(10) - 5) / 10000,
        long + (Random().nextInt(10) - 5) / 10000,
      );
    });
  }
}
