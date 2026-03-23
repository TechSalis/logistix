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

class AuthRemoteDataSourceImpl extends BaseRemoteDataSource
    implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(super.graphql);

  @override
  Future<void> updateFcmToken(String token) async {
    const mutation = r'''
        mutation UpdateFcmToken($token: String!) {
          updateFcmToken(token: $token)
        }
      ''';

    final result = await gqlService.mutate(
      mutation,
      variables: {'token': token},
    );

    result.throwIfException();
  }

  @override
  Future<(OAuthToken, UserDto)> login(String email, String password) async {
    const mutation =
        '''
        mutation Login(\$email: String!, \$password: String!) {
          login(email: \$email, password: \$password) {
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
      key: 'login',
      variables: {'email': email, 'password': password},
    );

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
  }

  @override
  Future<(OAuthToken, UserDto)> signUp(
    String email,
    String password,
    String name,
  ) async {
    const mutation =
        '''
        mutation Register(\$input: RegisterInput!) {
          register(input: \$input) {
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
      key: 'register',
      variables: {
        'input': {'email': email, 'password': password, 'fullName': name},
      },
    );

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
  }

  @override
  Future<void> sendPasswordResetOtp(String email) async {
    const mutation = r'''
        mutation SendPasswordResetOtp($email: String!) {
          sendPasswordResetOtp(email: $email)
        }
      ''';

    final result = await gqlService.mutate(
      mutation,
      variables: {'email': email},
    );

    result.throwIfException();
  }

  @override
  Future<void> verifyOtp(String email, String otp) async {
    const mutation = r'''
        mutation VerifyOtp($email: String!, $otp: String!) {
          verifyOtp(email: $email, otp: $otp)
        }
      ''';

    final result = await gqlService.mutate(
      mutation,
      variables: {'email': email, 'otp': otp},
    );

    result.throwIfException();
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    const mutation = r'''
        mutation ResetPassword($email: String!, $newPassword: String!) {
          resetPassword(email: $email, newPassword: $newPassword)
        }
      ''';

    final result = await gqlService.mutate(
      mutation,
      variables: {'email': email, 'newPassword': newPassword},
    );

    result.throwIfException();
  }
}
