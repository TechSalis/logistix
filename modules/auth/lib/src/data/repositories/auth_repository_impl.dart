import 'package:auth/src/data/datasources/auth_remote_datasource.dart';
import 'package:auth/src/data/dtos/login_request.dart';
import 'package:auth/src/data/dtos/reset_password_request.dart';
import 'package:auth/src/data/dtos/sign_up_request.dart';
import 'package:auth/src/data/dtos/verify_otp_request.dart';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:shared/shared.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._dataSource, this._tokenStore);

  final AuthRemoteDataSource _dataSource;
  final TokenStore _tokenStore;

  @override
  Future<Result<AppError, User>> login(String email, String password) async {
    return Result.tryCatch<AppError, User>(() async {
      final loginData = await _dataSource.login(
        LoginRequest(email: email, password: password),
      );

      final token = loginData.$1;
      final userDto = loginData.$2;

      // Save token using OAuthToken model
      await _tokenStore.write(token);

      return userDto.toEntity();
    });
  }

  @override
  Future<Result<AppError, User>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return Result.tryCatch<AppError, User>(() async {
      final signUpData = await _dataSource.signUp(
        SignUpRequest(email: email, password: password, name: name),
      );

      final token = signUpData.$1;
      final userDto = signUpData.$2;

      await _tokenStore.write(token);

      return userDto.toEntity();
    });
  }

  @override
  Future<Result<AppError, void>> sendPasswordResetOtp({
    required String email,
  }) async {
    return Result.tryCatch<AppError, void>(() async {
      await _dataSource.sendPasswordResetOtp(email);
    });
  }

  @override
  Future<Result<AppError, void>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return Result.tryCatch<AppError, void>(() async {
      await _dataSource.verifyOtp(VerifyOtpRequest(email: email, otp: otp));
    });
  }

  @override
  Future<Result<AppError, void>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    return Result.tryCatch<AppError, void>(() async {
      await _dataSource.resetPassword(
        ResetPasswordRequest(email: email, newPassword: newPassword),
      );
    });
  }

  @override
  Future<Result<AppError, void>> updateFcmToken(String token) async {
    return Result.tryCatch<AppError, void>(() async {
      await _dataSource.updateFcmToken(token);
    });
  }

  @override
  Future<Result<AppError, void>> deactivateAccount() async {
    return Result.tryCatch<AppError, void>(() async {
      await _dataSource.deactivateAccount();
    });
  }
}
