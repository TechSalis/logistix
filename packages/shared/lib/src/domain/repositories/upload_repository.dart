import 'dart:io';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

abstract class UploadRepository {
  Future<Result<AppError, PresignedUrl>> getPresignedUrl(String fileName);
  Future<Result<AppError, void>> uploadFile(File file, String url);
}
