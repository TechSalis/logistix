import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';

abstract class RiderRepo {
  Future<Either<AppError, Iterable<RiderData>>> findRiders([
    Coordinates? location,
  ]);
  Stream<Coordinates> listenToRiderCoordinates(RiderData rider);
}
