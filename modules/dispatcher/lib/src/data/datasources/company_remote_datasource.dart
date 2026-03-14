import 'package:bootstrap/definitions/app_error.dart';
import 'package:shared/shared.dart';

// ignore: one_member_abstracts
abstract class CompanyRemoteDataSource {
  Future<CompanyDto> getCompany(String id);
}

class CompanyRemoteDataSourceImpl implements CompanyRemoteDataSource {
  CompanyRemoteDataSourceImpl(this._gqlService);
  final GraphQLService _gqlService;

  @override
  Future<CompanyDto> getCompany(String id) async {
    const query = r'''
      query GetCompany($id: ID!) {
        company(id: $id) {
          id
          name
          logoUrl
          cac
          address
          phoneNumber
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await _gqlService.query(query, variables: {'id': id});
    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['company'];
    if (data == null) throw const AppError(message: 'Company not found');

    return CompanyDto.fromJson(data as Map<String, dynamic>);
  }
}
