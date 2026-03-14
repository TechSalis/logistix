import 'package:auth/src/core/error_codes.dart';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/interfaces/http/oauth_token/models/codec.dart';
import 'package:bootstrap/interfaces/http/oauth_token/models/oauth_token.dart';
import 'package:shared/shared.dart';

/// Remote data source for authentication operations
abstract class AuthRemoteDataSource {
  /// Login with email and password
  Future<(OAuthToken, UserDto)> login(String email, String password);

  /// Sign up with email, password and name
  Future<(OAuthToken, UserDto)> signUp(
    String email,
    String password,
    String name,
  );

  /// Send password reset OTP
  Future<void> sendPasswordResetOtp(String email);

  /// Verify OTP
  Future<void> verifyOtp(String email, String otp);

  /// Reset password
  Future<void> resetPassword(String email, String newPassword);

  /// Update FCM token
  Future<void> updateFcmToken(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._graphql);
  final GraphQLService _graphql;

  @override
  Future<void> updateFcmToken(String token) async {
    try {
      const mutation = r'''
        mutation UpdateFcmToken($token: String!) {
          updateFcmToken(token: $token)
        }
      ''';

      final result = await _graphql.mutate(
        mutation,
        variables: {'token': token},
      );

      if (result.hasException) {
        throw ErrorHandler.fromException(result.exception);
      }
    } catch (e) {
      throw ErrorHandler.fromException(e);
    }
  }

  @override
  Future<(OAuthToken, UserDto)> login(String email, String password) async {
    try {
      const mutation = r'''
        mutation Login($email: String!, $password: String!) {
          login(email: $email, password: $password) {
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
              isOnboarded
              companyId
            }
          }
        }
      ''';

      final result = await _graphql.mutate(
        mutation,
        variables: {'email': email, 'password': password},
      );

      if (result.hasException) {
        throw ErrorHandler.fromException(result.exception);
      }

      final data = result.data?['login'];
      if (data == null) {
        throw const AppError(
          message: 'Invalid response from server',
          code: AuthErrorCodes.invalidResponse,
        );
      }

      final tokenData = data['token'];
      if (tokenData == null) {
        throw const AppError(
          message: 'Token not found in server response',
          code: AuthErrorCodes.missingToken,
        );
      }

      final token = const OAuthTokenCodec().decode(tokenData);
      if (token == null) {
        throw const AppError(
          message: 'Invalid token format from server',
          code: AuthErrorCodes.invalidToken,
        );
      }

      final userDto = UserDto.fromJson(data['user'] as Map<String, dynamic>);

      return (token, userDto);
    } catch (e) {
      if (e is AppError) rethrow;
      throw ErrorHandler.fromException(e);
    }
  }

  @override
  Future<(OAuthToken, UserDto)> signUp(
    String email,
    String password,
    String name,
  ) async {
    try {
      const mutation = r'''
        mutation Register($input: RegisterInput!) {
          register(input: $input) {
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
              isOnboarded
              companyId
            }
          }
        }
      ''';

      final result = await _graphql.mutate(
        mutation,
        variables: {
          'input': {'email': email, 'password': password, 'fullName': name},
        },
      );

      if (result.hasException) {
        throw ErrorHandler.fromException(result.exception);
      }

      final data = result.data?['register'];
      if (data == null) {
        throw const AppError(
          message: 'Invalid response from server',
          code: AuthErrorCodes.invalidResponse,
        );
      }

      final tokenData = data['token'];
      if (tokenData == null) {
        throw const AppError(
          message: 'Token not found in server response',
          code: AuthErrorCodes.missingToken,
        );
      }

      final token = const OAuthTokenCodec().decode(tokenData);
      if (token == null) {
        throw const AppError(
          message: 'Invalid token format from server',
          code: AuthErrorCodes.invalidToken,
        );
      }

      final userDto = UserDto.fromJson(data['user'] as Map<String, dynamic>);

      return (token, userDto);
    } catch (e) {
      if (e is AppError) rethrow;
      throw ErrorHandler.fromException(e);
    }
  }

  @override
  Future<void> sendPasswordResetOtp(String email) async {
    try {
      const mutation = r'''
        mutation SendPasswordResetOtp($email: String!) {
          sendPasswordResetOtp(email: $email)
        }
      ''';

      final result = await _graphql.mutate(
        mutation,
        variables: {'email': email},
      );

      if (result.hasException) {
        throw ErrorHandler.fromException(result.exception);
      }
    } catch (e) {
      if (e is AppError) rethrow;
      throw ErrorHandler.fromException(e);
    }
  }

  @override
  Future<void> verifyOtp(String email, String otp) async {
    try {
      const mutation = r'''
        mutation VerifyOtp($email: String!, $otp: String!) {
          verifyOtp(email: $email, otp: $otp)
        }
      ''';

      final result = await _graphql.mutate(
        mutation,
        variables: {'email': email, 'otp': otp},
      );

      if (result.hasException) {
        throw ErrorHandler.fromException(result.exception);
      }
    } catch (e) {
      if (e is AppError) rethrow;
      throw ErrorHandler.fromException(e);
    }
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    try {
      const mutation = r'''
        mutation ResetPassword($email: String!, $newPassword: String!) {
          resetPassword(email: $email, newPassword: $newPassword)
        }
      ''';

      final result = await _graphql.mutate(
        mutation,
        variables: {'email': email, 'newPassword': newPassword},
      );

      if (result.hasException) {
        throw ErrorHandler.fromException(result.exception);
      }
    } catch (e) {
      if (e is AppError) rethrow;
      throw ErrorHandler.fromException(e);
    }
  }
}
