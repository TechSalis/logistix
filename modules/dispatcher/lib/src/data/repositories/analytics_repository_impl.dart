import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/data/datasources/analytics_remote_datasource.dart';
import 'package:dispatcher/src/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl(this._dataSource);
  final AnalyticsRemoteDataSource _dataSource;

  @override
  Future<Result<AppError, String>> exportOrdersCsv({
    DateTime? startDate,
    DateTime? endDate,
    String? riderId,
  }) async {
    return Result.tryCatch(
      () => _dataSource.exportOrdersCsv(
        startDate: startDate,
        endDate: endDate,
        riderId: riderId,
      ),
    );
  }

  @override
  Future<Result<AppError, String>> exportAnalyticsSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return Result.tryCatch(
      () => _dataSource.exportAnalyticsSummary(
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }
}
