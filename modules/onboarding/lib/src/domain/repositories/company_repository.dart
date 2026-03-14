import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

// ignore: one_member_abstracts
abstract class CompanyRepository {
  Future<Result<AppError, PaginatedResult<Company>>> getCompanies({
    String? search,
    int page = 1,
    int perPage = 20,
  });
}
