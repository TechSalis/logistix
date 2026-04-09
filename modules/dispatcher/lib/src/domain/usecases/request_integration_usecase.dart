import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/definitions/usecase.dart';
import 'package:dispatcher/src/domain/repositories/contact_repository.dart';
import 'package:shared/shared.dart';

class RequestIntegrationUseCase
    extends ResultUseCaseWithParams<AppError, CompanyIntegration, ActivationRequestDto> {

  RequestIntegrationUseCase(this._repository);
  final ContactRepository _repository;

  @override
  Future<Result<AppError, CompanyIntegration>> call(ActivationRequestDto params) {
    return _repository.requestIntegration(params);
  }
}
