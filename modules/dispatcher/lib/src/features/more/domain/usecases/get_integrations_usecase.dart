import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/definitions/usecase.dart';
import 'package:dispatcher/src/features/more/domain/repositories/contact_repository.dart';
import 'package:shared/shared.dart';

class GetIntegrationsUseCase
    extends ResultUseCase<AppError, List<CompanyIntegration>> {
  GetIntegrationsUseCase(this._repository);
  final ContactRepository _repository;

  @override
  Future<Result<AppError, List<CompanyIntegration>>> call() {
    return _repository.getIntegrations();
  }
}
