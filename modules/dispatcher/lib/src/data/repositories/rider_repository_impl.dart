import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/data/datasources/rider_remote_datasource.dart';
import 'package:dispatcher/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

class RiderRepositoryImpl implements RiderRepository {
  const RiderRepositoryImpl(this._dataSource);
  final RiderRemoteDataSource _dataSource;

  @override
  Future<Result<AppError, List<Rider>>> getPendingRiders() async {
    return Result.tryCatch(() async {
      final dtos = await _dataSource.getPendingRiders();
      return dtos.map((dto) => dto.toEntity()).toList();
    });
  }

  @override
  Future<Result<AppError, List<Rider>>> getRiders({
    String? search,
    int? limit,
    int? offset,
  }) async {
    return Result.tryCatch(() async {
      final dtos = await _dataSource.getRiders(
        search: search,
        limit: limit,
        offset: offset,
      );
      return dtos.map((dto) => dto.toEntity()).toList();
    });
  }

  @override
  Future<Result<AppError, List<RiderLocationInfo>>> getRiderLocations() async {
    return Result.tryCatch(() async {
      final dtos = await _dataSource.getRiderLocations();
      return dtos.map((dto) => dto.toEntity()).toList();
    });
  }

  @override
  Future<Result<AppError, void>> acceptRider(String riderId) async {
    return Result.tryCatch(() => _dataSource.acceptRider(riderId));
  }

  @override
  Future<Result<AppError, void>> rejectRider(String riderId) async {
    return Result.tryCatch(() => _dataSource.rejectRider(riderId));
  }

  @override
  Future<Result<AppError, Rider>> getRider(String id) async {
    return Result.tryCatch(() async {
      final dto = await _dataSource.getRider(id);
      return dto.toEntity();
    });
  }
}
