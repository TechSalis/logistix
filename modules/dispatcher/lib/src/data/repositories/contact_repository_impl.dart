import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/data/datasources/contact_remote_datasource.dart';
import 'package:dispatcher/src/domain/repositories/contact_repository.dart';
import 'package:shared/shared.dart';

class ContactRepositoryImpl implements ContactRepository {
  ContactRepositoryImpl(this._remoteDataSource);
  final ContactRemoteDataSource _remoteDataSource;

  @override
  Future<Result<AppError, CompanyIntegration>> requestIntegration(
    ActivationRequestDto request,
  ) async {
    return Result.tryCatch(() => _remoteDataSource.requestIntegration(request));
  }

  @override
  Future<Result<AppError, List<CompanyIntegration>>> getIntegrations() async {
    return Result.tryCatch(_remoteDataSource.getIntegrations);
  }
}
