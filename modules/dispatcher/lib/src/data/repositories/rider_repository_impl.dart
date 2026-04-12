import 'dart:async';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/data/datasources/rider_remote_datasource.dart';
import 'package:dispatcher/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

class RiderRepositoryImpl implements RiderRepository {
  RiderRepositoryImpl(this._dataSource, this._riderDao);
  final RiderRemoteDataSource _dataSource;
  final RiderDao _riderDao;


  @override
  Stream<Rider?> watchRider(String id) => _riderDao.watchRider(id);

  @override
  Stream<List<Rider>> watchRiders({
    String? searchQuery,
    List<RiderStatus>? statuses,
    int? limit,
    String? afterFullName,
    String? afterId,
  }) {
    return _riderDao.watchRiders(
      searchQuery: searchQuery,
      statuses: statuses?.map((e) => e.value).toList(),
      limit: limit,
      afterFullName: afterFullName,
      afterId: afterId,
    );
  }

  @override
  Future<Result<AppError, List<Rider>>> getRiders({
    String? searchQuery,
    List<RiderStatus>? statuses,
    int limit = 20,
    String? afterFullName,
    String? afterId,
  }) async {
    try {
      final riders = await _riderDao.getRiders(
        searchQuery: searchQuery,
        statuses: statuses?.map((e) => e.value).toList(),
        limit: limit,
        afterFullName: afterFullName,
        afterId: afterId,
      );
      return Result.data(riders);
    } catch (e) {
      return Result.error(AppError(message: e.toString()));
    }
  }

  @override
  Future<Result<AppError, Rider?>> getRider(String riderId) async {
    try {
      final rider = await _riderDao.getRider(riderId);
      return Result.data(rider);
    } catch (e) {
      return Result.error(AppError(message: e.toString()));
    }
  }

  @override
  Future<Result<AppError, void>> acceptRider(String riderId) async {
    try {
      final dto = await _dataSource.acceptRider(riderId);
      await _riderDao.upsertRider(dto.toDriftCompanion());
      return const Result.data(null);
    } catch (e) {
      return Result.error(AppError(message: e.toString()));
    }
  }

  @override
  Future<Result<AppError, void>> rejectRider(String riderId) async {
    try {
      await _dataSource.rejectRider(riderId);
      await _riderDao.deleteRider(riderId);
      return const Result.data(null);
    } catch (e) {
      return Result.error(AppError(message: e.toString()));
    }
  }
}
