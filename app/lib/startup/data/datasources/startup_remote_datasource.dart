import 'package:bootstrap/definitions/app_error.dart';
import 'package:shared/shared.dart';

abstract class StartupRemoteDataSource {
  Future<UserDto?> getCurrentUser();
}

class StartupRemoteDataSourceImpl implements StartupRemoteDataSource {
  const StartupRemoteDataSourceImpl(this._graphql);
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
            isOnboarded
            companyId
          }
        }
      ''';

      final result = await _graphql.query(query);

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
}
