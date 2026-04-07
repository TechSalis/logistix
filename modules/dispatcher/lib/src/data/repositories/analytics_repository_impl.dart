import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/data/datasources/analytics_remote_datasource.dart';
import 'package:dispatcher/src/domain/repositories/analytics_repository.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl(this._dataSource);
  final AnalyticsRemoteDataSource _dataSource;

  @override
  Future<Result<AppError, String>> exportAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? riderId,
  }) async {
    return Result.tryCatch(
      () => _dataSource.exportAnalytics(
        startDate: startDate,
        endDate: endDate,
        riderId: riderId,
      ),
    );
  }
}
