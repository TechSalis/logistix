import 'dart:math';

import 'package:logistix/features/location/domain/entities/coordinate.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';
import 'package:logistix/features/rider/domain/repository/rider_repo.dart';

class RandomRiderRepoImpl extends RiderRepo {
  @override
  Stream<Coordinates> listenToRiderCoordinates(Rider rider) {
    double lat = 6.5244, long = 3.3792;
    return Stream.periodic(const Duration(seconds: 2), (computationCount) {
      return Coordinates(
        lat + (Random().nextInt(10) - 5) / 10000,
        long + (Random().nextInt(10) - 5) / 10000,
      );
    });
  }
}
