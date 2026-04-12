import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/features/more/data/dtos/activation_request_dto.dart';
import 'package:shared/shared.dart';

abstract class ContactRepository {
  Future<Result<AppError, CompanyIntegration>> requestIntegration(
    ActivationRequestDto request,
  );

  Future<Result<AppError, List<CompanyIntegration>>> getIntegrations();
}
