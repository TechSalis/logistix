import 'dart:math';

import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/core/entities/rider_data.dart';
import 'package:logistix/features/rider/domain/repository/rider_repo.dart';

class RandomRiderRepoImpl extends RiderRepo {
  @override
  Stream<Coordinates> listenToRiderCoordinates(RiderData rider) async* {
    double lat = 6.5244, long = 3.3792;
    yield Coordinates(
      lat += (Random().nextInt(10) - 5) / 10000,
      long += (Random().nextInt(10) - 5) / 10000,
    );
    yield* Stream.periodic(const Duration(seconds: 5), (computationCount) {
      return Coordinates(
        lat += (Random().nextInt(10) - 5) / 10000,
        long += (Random().nextInt(10) - 5) / 10000,
      );
    });
  }
}
