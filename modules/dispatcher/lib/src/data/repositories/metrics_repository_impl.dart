import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/data/datasources/metrics_remote_datasource.dart';
import 'package:dispatcher/src/domain/repositories/metrics_repository.dart';
import 'package:shared/shared.dart';

class MetricsRepositoryImpl implements MetricsRepository {
  const MetricsRepositoryImpl(this._dataSource);
  final MetricsRemoteDataSource _dataSource;

  @override
  Future<Result<AppError, Metrics>> getMetrics() async {
    return Result.tryCatch(() async {
      final dto = await _dataSource.getMetrics();
      return dto.toEntity();
    });
  }
}
