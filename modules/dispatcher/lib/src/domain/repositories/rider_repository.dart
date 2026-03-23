import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

abstract class RiderRepository {
  Stream<List<Rider>> watchRiders({String? searchQuery});
  Future<Result<AppError, List<Rider>>> getRiders({
    String? searchQuery,
    List<RiderStatus>? statuses,
  });
  Future<Result<AppError, Rider?>> getRider(String riderId);
  Future<Result<AppError, void>> acceptRider(String riderId);
  Future<Result<AppError, void>> rejectRider(String riderId);
}
