import 'package:shared/shared.dart';

abstract class ContactRemoteDataSource {
  Future<void> requestIntegration(ActivationRequestDto request);
}

class ContactRemoteDataSourceImpl extends BaseRemoteDataSource implements ContactRemoteDataSource {
  ContactRemoteDataSourceImpl(super.gqlService);

  @override
  Future<void> requestIntegration(ActivationRequestDto request) async {
    const mutation = r'''
      mutation RequestIntegration($platform: Platform!, $name: String!, $phone: String!, $email: String!) {
        requestIntegration(platform: $platform, name: $name, phone: $phone, email: $email)
      }
    ''';

    await mutate<void>(
      mutation,
      variables: request.toJson(),
      key: 'requestIntegration',
    );
  }
}
