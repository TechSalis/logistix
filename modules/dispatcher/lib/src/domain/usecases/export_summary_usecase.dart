import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/domain/repositories/analytics_repository.dart';

class ExportSummaryUseCase {
  ExportSummaryUseCase(this._repository);
  final AnalyticsRepository _repository;

  Future<Result<AppError, String>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _repository.exportAnalyticsSummary(
      startDate: startDate,
      endDate: endDate,
    );
  }
}
