import 'package:dio/dio.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/features/account/domain/repository/account_repository.dart';

class AccountRepositoryImpl extends AccountRepository {
  AccountRepositoryImpl({required this.client});
  final Dio client;

  @override
  Future<Either<AppError, dynamic>> updateFCM(String token) async {
    final response =
        await client
            .post('/account/fcm', data: {'fcm_token': token})
            .handleDioException();

    return response.toAppErrorOr((res) {});
  }

  @override
  Future<Either<AppError, void>> removeFCM(String token) async {
    final response =
        await client
            .delete('/account/fcm', data: {'fcm_token': token})
            .handleDioException();
    return response.toAppErrorOr((res) {});
  }
}
