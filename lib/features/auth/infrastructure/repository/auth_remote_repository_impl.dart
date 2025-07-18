import 'package:dio/dio.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/core/utils/extensions/dio.dart';
import 'package:logistix/features/auth/domain/entities/user_session.dart';
import 'package:logistix/features/auth/domain/repository/auth_remote_repository.dart';
import 'package:logistix/features/auth/infrastructure/models/auth_dto.dart';

class AuthRepositoryImpl extends AuthRepository {
  AuthRepositoryImpl({required this.client});
  final Dio client;

  @override
  Future<Either<AppError, AuthLoginResponse>> login(LoginData data) async {
    final res = await client.post('/auth/login', data: data.toJson());
    return res.toAppErrorOr((res) => AuthLoginResponse.fromJson(res.data));
  }

  @override
  Future<Either<AppError, AuthLoginResponse>> loginAnonymously(
    UserRole role,
  ) async {
    final res = await client.post(
      '/auth/anonymous/login',
      data: {'role': role.name},
    );
    return res.toAppErrorOr((res) => AuthLoginResponse.fromJson(res.data));
  }

  @override
  Future<Either<AppError, void>> logout() async {
    final res = await client.post('/auth/logout');
    return res.toAppErrorOr((res) {});
  }

  @override
  Future<Either<AppError, AuthLoginResponse>> signup(
    LoginData data,
    UserRole role,
  ) async {
    final res = await client.post(
      '/auth/signup',
      data: {...data.toJson(), 'role': role.name},
    );
    return res.toAppErrorOr((res) => AuthLoginResponse.fromJson(res.data));
  }
}
