import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/data/datasources/company_remote_datasource.dart';
import 'package:dispatcher/src/domain/repositories/company_repository.dart';
import 'package:shared/shared.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  const CompanyRepositoryImpl(this._dataSource);
  final CompanyRemoteDataSource _dataSource;

  @override
  Future<Result<AppError, Company>> getCompany(String id) async {
    return await Result.tryCatch<AppError, Company>(() async {
      final dto = await _dataSource.getCompany(id);
      return dto.toEntity();
    });
  }
}
