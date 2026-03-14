import 'package:bootstrap/definitions/app_error.dart';
import 'package:shared/shared.dart';

/// Remote data source for company operations.
// ignore: one_member_abstracts
abstract class CompanyRemoteDataSource {
  Future<({List<CompanyDto> items, int total})> getCompanies({
    String? search,
    int page = 1,
    int perPage = 20,
  });
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  CompanyRemoteDataSourceImpl(this._graphql);
  final GraphQLService _graphql;

  @override
  Future<({List<CompanyDto> items, int total})> getCompanies({
    String? search,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      const query = r'''
        query GetCompanies($search: String, $page: Int!, $perPage: Int!) {
          companies(search: $search, page: $page, perPage: $perPage) {
            items {
              id
              name
              address
            }
            total
          }
        }
      ''';

      final result = await _graphql.query(
        query,
        variables: {'search': search, 'page': page, 'perPage': perPage},
      );

      if (result.hasException) {
        throw ErrorHandler.fromException(result.exception);
      }

      final data = result.data?['companies'];
      final rawItems = (data?['items'] as List).cast<Map<String, dynamic>?>();
      final total = (data?['total'] as num?)?.toInt() ?? 0;

      return (
        items: rawItems.nonNulls.map(CompanyDto.fromJson).toList(),
        total: total,
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw ErrorHandler.fromException(e);
    }
  }
}
