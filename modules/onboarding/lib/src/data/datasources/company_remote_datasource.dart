import 'package:bootstrap/definitions/app_error.dart';
import 'package:shared/shared.dart';

/// Remote data source for company operations.
// ignore: one_member_abstracts
abstract class CompanyRemoteDataSource {
  Future<({List<CompanyDto> items, int total})> getCompanies({
    String? search,
    int limit = 20,
    int offset = 0,
  });
}

class CompanyRemoteDataSourceImpl extends BaseRemoteDataSource
    implements CompanyRemoteDataSource {
  CompanyRemoteDataSourceImpl(super.graphql);

  @override
  Future<({List<CompanyDto> items, int total})> getCompanies({
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      const queryDocument = r'''
        query GetCompanies($search: String, $limit: Int!, $offset: Int!) {
          companies(search: $search, limit: $limit, offset: $offset) {
            items {
              id
              name
              address
            }
            total
          }
        }
      ''';

      final data = await query<Map<String, dynamic>>(
        queryDocument,
        variables: {'search': search, 'limit': limit, 'offset': offset},
        key: 'companies',
      );

      final rawItems = (data['items'] as List).cast<Map<String, dynamic>>();
      final total = (data['total'] as num?)?.toInt() ?? 0;

      return (
        items: rawItems.map(CompanyDto.fromJson).toList(),
        total: total,
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw ErrorHandler.fromException(e);
    }
  }
}
