import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/features/more/domain/repositories/analytics_repository.dart';

class ExportAnalyticsUseCase {
  ExportAnalyticsUseCase(this._repository);
  final AnalyticsRepository _repository;

  Future<Result<AppError, String>> call({
    DateTime? startDate,
    DateTime? endDate,
    String? riderId,
  }) {
    return _repository.exportAnalytics(
      startDate: startDate,
      endDate: endDate,
      riderId: riderId,
    );
  }
}
