import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';

abstract class UploadImageRepo {
  Future<Either<AppError, String>> uploadImage(String path);
}
