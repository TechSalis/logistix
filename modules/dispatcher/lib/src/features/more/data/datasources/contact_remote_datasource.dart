import 'package:dispatcher/src/features/more/data/dtos/activation_request_dto.dart';
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
    const mutationDoc = r'''
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
      mutationDoc,
      variables: request.toJson(),
      key: 'requestIntegration',
    );

    return CompanyIntegrationDto.fromJson(result).toEntity();
  }

  @override
  Future<List<CompanyIntegration>> getIntegrations() async {
    const queryDoc = '''
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

    final result = await query<List<dynamic>>(
      queryDoc,
      key: 'integrations',
    );

    return result
        .map((json) => CompanyIntegrationDto.fromJson(json as Map<String, dynamic>))
        .map((dto) => dto.toEntity())
        .toList();
  }
}
