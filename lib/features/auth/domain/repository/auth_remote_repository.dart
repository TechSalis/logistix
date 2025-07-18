import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/features/auth/domain/entities/user_session.dart';
import 'package:logistix/features/auth/infrastructure/models/auth_dto.dart';

abstract class AuthRepository {
  Future<Either<AppError, AuthLoginResponse>> login(LoginData data);
  Future<Either<AppError, void>> logout();
  Future<Either<AppError, AuthLoginResponse>> loginAnonymously(UserRole role);
  Future<Either<AppError, AuthLoginResponse>> signup(
    LoginData data,
    UserRole role,
  );
}
