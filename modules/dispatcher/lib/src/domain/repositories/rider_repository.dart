import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

abstract class RiderRepository {
  Future<Result<AppError, List<Rider>>> getPendingRiders();
  Future<Result<AppError, List<Rider>>> getRiders({
    String? search,
    int? limit,
    int? offset,
  });
  Future<Result<AppError, void>> acceptRider(String riderId);
  Future<Result<AppError, void>> rejectRider(String riderId);
  Future<Result<AppError, List<RiderLocationInfo>>> getRiderLocations();
  Future<Result<AppError, Rider>> getRider(String id);
}
