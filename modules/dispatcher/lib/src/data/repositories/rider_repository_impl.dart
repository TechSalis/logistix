import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/data/datasources/rider_remote_datasource.dart';
import 'package:dispatcher/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

class RiderRepositoryImpl implements RiderRepository {
  const RiderRepositoryImpl(this._dataSource, this._riderDao);
  final RiderRemoteDataSource _dataSource;
  final RiderDao _riderDao;

  @override
  Stream<List<Rider>> watchRiders({String? searchQuery}) {
    return _riderDao.watchRiders(searchQuery: searchQuery);
  }

  @override
  Future<Result<AppError, List<Rider>>> getRiders({
    String? searchQuery,
    List<RiderStatus>? statuses,
  }) async {
    return Result.tryCatch(() async {
      return _riderDao.searchRiders(
        searchQuery: searchQuery,
        statuses: statuses?.map((e) => e.value).toList(),
      );
    });
  }

  @override
  Future<Result<AppError, Rider?>> getRider(String riderId) async {
    return Result.tryCatch(() async {
      return _riderDao.getRider(riderId);
    });
  }

  @override
  Future<Result<AppError, void>> acceptRider(String riderId) async {
    return Result.tryCatch(() async {
      final dto = await _dataSource.acceptRider(riderId);
      await _riderDao.upsertRider(dto.toDriftCompanion());
    });
  }

  @override
  Future<Result<AppError, void>> rejectRider(String riderId) async {
    return Result.tryCatch(() async {
      await _dataSource.rejectRider(riderId);
      await _riderDao.deleteRider(riderId);
    });
  }
}
