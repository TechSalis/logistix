import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';

abstract class AccountRepository {
  Future<Either<AppError, void>> updateFCM(String token);
  Future<Either<AppError, void>> removeFCM(String token);
}
