import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/features/more/data/datasources/analytics_remote_datasource.dart';
import 'package:dispatcher/src/features/more/data/dtos/analytics_export_request.dart';
import 'package:dispatcher/src/features/more/domain/repositories/analytics_repository.dart';
import 'package:shared/shared.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  const AnalyticsRepositoryImpl(this._dataSource);
  final AnalyticsRemoteDataSource _dataSource;

  @override
  Future<Result<AppError, String>> exportAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? riderId,
    List<OrderStatus>? statuses,
  }) async {
    return Result.tryCatch(
      () => _dataSource.exportAnalytics(
        AnalyticsExportRequest(
          startDate: startDate,
          endDate: endDate,
          riderId: riderId,
          statuses: statuses,
        ),
      ),
    );
  }
}
