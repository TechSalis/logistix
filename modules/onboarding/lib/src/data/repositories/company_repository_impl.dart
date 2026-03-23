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
    int limit = 20,
    int offset = 0,
  }) async {
    return await Result.tryCatch<AppError, PaginatedResult<Company>>(() async {
      final (:items, :total) = await _dataSource.getCompanies(
        search: search,
        limit: limit,
        offset: offset,
      );

      return PaginatedResult(
        items: items.map((dto) => dto.toEntity()).toList(),
        total: total,
        limit: limit,
        offset: offset,
      );
    });
  }
}
