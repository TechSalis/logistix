import 'dart:io';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

class UploadRepositoryImpl implements UploadRepository {
  UploadRepositoryImpl(this._dataSource);
  final UploadRemoteDataSource _dataSource;

  @override
  Future<Result<AppError, PresignedUrl>> getPresignedUrl(
    String fileName,
  ) async {
    return await Result.tryCatch<AppError, PresignedUrl>(() {
      return _dataSource.getPresignedUrl(fileName);
    });
  }

  @override
  Future<Result<AppError, void>> uploadFile(File file, String url) async {
    return await Result.tryCatch<AppError, void>(() {
      return _dataSource.uploadFile(file, url);
    });
  }
}
