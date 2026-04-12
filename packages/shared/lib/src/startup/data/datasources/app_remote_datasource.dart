import 'package:bootstrap/definitions/app_error.dart';
import 'package:shared/shared.dart';

abstract class AppRemoteDataSource {
  Future<UserDto?> getCurrentUser();
  Future<void> updateFcmToken(String token);
  Future<void> logout();
}

class AppRemoteDataSourceImpl implements AppRemoteDataSource {
  const AppRemoteDataSourceImpl(this._graphql);
  final GraphQLService _graphql;

  @override
  Future<UserDto?> getCurrentUser() async {
    try {
      const query = '''
        query Me {
          me {
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
      ''';

      final result = await _graphql.query<Map<String, dynamic>>(query);

      if (result.hasException) {
        throw ErrorHandler.fromException(result.exception);
      }

      final userData = result.data?['me'] as Map<String, dynamic>?;
      if (userData == null) return null;

      return UserDto.fromJson(userData);
    } catch (e) {
      if (e is AppError) rethrow;
      throw ErrorHandler.fromException(e);
    }
  }

  @override
  Future<void> updateFcmToken(String token) async {
    const mutation = r'''
        mutation UpdateFcmToken($token: String!) {
          updateFcmToken(token: $token)
        }
      ''';

    final result = await _graphql.mutate<Map<String, dynamic>>(
      mutation,
      variables: {'token': token},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }
  }

  @override
  Future<void> logout() async {
    const mutation = '''
        mutation Logout {
          logout
        }
      ''';

    final result = await _graphql.mutate<Map<String, dynamic>>(mutation);
    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }
  }
}
