import 'package:bootstrap/interfaces/http/oauth_token/models/codec.dart';
import 'package:bootstrap/interfaces/http/oauth_token/models/oauth_token.dart';
import 'package:onboarding/src/data/models/dispatcher_profile_dto.dart';
import 'package:onboarding/src/data/models/rider_profile_dto.dart';
import 'package:shared/shared.dart';

/// Remote data source for onboarding operations
abstract class OnboardingRemoteDataSource {
  /// Submit rider profile
  Future<(OAuthToken, UserDto)> submitRiderProfile(RiderProfileDto profile);

  /// Submit dispatcher profile
  Future<(OAuthToken, UserDto)> submitDispatcherProfile(
    DispatcherProfileDto profile,
  );

  /// Submit customer profile
  Future<(OAuthToken, UserDto)> submitCustomerProfile();
}

class OnboardingRemoteDataSourceImpl extends BaseRemoteDataSource
    implements OnboardingRemoteDataSource {
  OnboardingRemoteDataSourceImpl(super.graphql);

  @override
  Future<(OAuthToken, UserDto)> submitCustomerProfile() async {
    const mutation = '''
        mutation SubmitCustomerProfile {
          submitCustomerProfile {
            token {
              access_token
              refresh_token
              token_type
              expires_in
            }
            user {
              id
              email
              fullName
              role
              phoneNumber
              isOnboarded
            }
          }
        }
      ''';

    final data = await mutate<Map<String, dynamic>>(
      mutation,
      key: 'submitCustomerProfile',
    );

    final token = const OAuthTokenCodec().decode(data['token']);
    final userDto = UserDto.fromJson(data['user'] as Map<String, dynamic>);

    return (token!, userDto);
  }

  @override
  Future<(OAuthToken, UserDto)> submitRiderProfile(
    RiderProfileDto profile,
  ) async {
    const mutation =
        '''
        mutation SubmitRiderProfile(
          \$phoneNumber: String!
          \$registrationNumber: String!
          \$companyId: ID
        ) {
          submitRiderProfile(
            input: {
              phoneNumber: \$phoneNumber
              registrationNumber: \$registrationNumber
              companyId: \$companyId
            }
          ) {
            token {
              access_token
              refresh_token
              token_type
              expires_in
            }
            user {
              id
              email
              fullName
              role
              phoneNumber
              isOnboarded
              companyId
              riderProfile {
                ${GqlFragments.riderFields}
              }
              companyProfile {
                id
                name
                address
              }
            }
          }
        }
      ''';
    final data = await mutate<Map<String, dynamic>>(
      mutation,
      key: 'submitRiderProfile',
      variables: {
        'phoneNumber': profile.phoneNumber,
        'registrationNumber': profile.registrationNumber,
        'companyId': profile.companyId,
      },
    );

    final token = const OAuthTokenCodec().decode(data['token']);
    final userDto = UserDto.fromJson(data['user'] as Map<String, dynamic>);

    return (token!, userDto);
  }

  @override
  Future<(OAuthToken, UserDto)> submitDispatcherProfile(
    DispatcherProfileDto profile,
  ) async {
    // TODO: save address placeId or coordinates
    const mutation =
        '''
        mutation SubmitDispatcherProfile(
          \$companyName: String!
          \$phoneNumber: String!
          \$address: String!
          \$cac: String!
        ) {
          submitDispatcherProfile(
            input: {
              companyName: \$companyName
              phoneNumber: \$phoneNumber
              address: \$address
              cac: \$cac
            }
          ) {
            token {
              access_token
              refresh_token
              token_type
              expires_in
            }
            user {
              id
              email
              fullName
              role
              phoneNumber
              isOnboarded
              companyId
              riderProfile {
                ${GqlFragments.riderFields}
              }
              companyProfile {
                id
                name
                address
              }
            }
          }
        }
      ''';
      
    final data = await mutate<Map<String, dynamic>>(
      mutation,
      key: 'submitDispatcherProfile',
      variables: {
        'companyName': profile.companyName,
        'phoneNumber': profile.phoneNumber,
        'address': profile.address,
        'cac': profile.cac,
      },
    );

    final token = const OAuthTokenCodec().decode(data['token']);
    final userDto = UserDto.fromJson(data['user'] as Map<String, dynamic>);

    return (token!, userDto);
  }
}
