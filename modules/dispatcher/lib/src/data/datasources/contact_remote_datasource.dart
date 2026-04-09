import 'package:shared/shared.dart';

abstract class ContactRemoteDataSource {
  Future<CompanyIntegration> requestIntegration(ActivationRequestDto request);
  Future<List<CompanyIntegration>> getIntegrations();
}

class ContactRemoteDataSourceImpl extends BaseRemoteDataSource
    implements ContactRemoteDataSource {
  ContactRemoteDataSourceImpl(super.gqlService);

  @override
  Future<CompanyIntegration> requestIntegration(
    ActivationRequestDto request,
  ) async {
    const mutation = r'''
      mutation RequestIntegration($platform: Platform!, $name: String!, $phone: String!, $email: String!) {
        requestIntegration(platform: $platform, name: $name, phone: $phone, email: $email) {
          id
          platform
          platformId
          isActive
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await mutate<Map<String, dynamic>>(
      mutation,
      variables: request.toJson(),
      key: 'requestIntegration',
    );

    return CompanyIntegrationDto.fromJson(result).toEntity();
  }

  @override
  Future<List<CompanyIntegration>> getIntegrations() async {
    const query = '''
      query GetIntegrations {
        integrations {
          id
          platform
          platformId
          isActive
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await queryList<Map<String, dynamic>>(
      query,
      key: 'integrations',
    );

    return result
        .map(CompanyIntegrationDto.fromJson)
        .map((e) => e.toEntity())
        .toList();
  }
}
