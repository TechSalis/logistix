import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

abstract class AuthRepository {
  Future<Result<AppError, User>> login(String email, String password);
  Future<Result<AppError, User>> signUp({
    required String email,
    required String password,
    required String name,
  });
  Future<Result<AppError, void>> sendPasswordResetOtp({required String email});
  Future<Result<AppError, void>> verifyOtp({
    required String email,
    required String otp,
  });
  Future<Result<AppError, void>> resetPassword({
    required String email,
    required String newPassword,
  });
  Future<Result<AppError, void>> updateFcmToken(String token);
}
