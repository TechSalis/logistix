import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:onboarding/src/data/datasources/company_remote_datasource.dart';
import 'package:onboarding/src/domain/repositories/company_repository.dart';
import 'package:shared/shared.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl(this._dataSource);
  final CompanyRemoteDataSource _dataSource;

  @override
  Future<Result<AppError, PaginatedResult<Company>>> getCompanies({
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    return await Result.tryCatch<AppError, PaginatedResult<Company>>(() async {
      final (:items, :total) = await _dataSource.getCompanies(
        search: search,
        page: page,
        perPage: perPage,
      );

      return PaginatedResult(
        items: items.map((dto) => dto.toEntity()).toList(),
        total: total,
        page: page,
        perPage: perPage,
      );
    });
  }
}
