import 'dart:async';
import 'dart:io';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:shared/shared.dart';

abstract class UploadRemoteDataSource {
  Future<PresignedUrl> getPresignedUrl(String fileName);
  Future<void> uploadFile(File file, String url);
}

class UploadRemoteDataSourceImpl implements UploadRemoteDataSource {
  UploadRemoteDataSourceImpl(this._graphQLService);
  final GraphQLService _graphQLService;

  @override
  Future<PresignedUrl> getPresignedUrl(String fileName) async {
    const mutation = r'''
      mutation GetPresignedUrl($fileName: String!, $contentType: String!) {
        getPresignedUploadUrl(fileName: $fileName, contentType: $contentType) {
          url
          key
        }
      }
    ''';

    final contentType = lookupMimeType(fileName);

    final result = await _graphQLService.mutate(
      mutation,
      variables: {'fileName': fileName, 'contentType': contentType},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['getPresignedUploadUrl'];
    if (data == null) {
      throw const AppError(
        message: 'Failed to get presigned URL: No data returned',
      );
    }

    return PresignedUrl.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> uploadFile(File file, String url) async {
    try {
      // Validate file exists
      final exists = file.existsSync();
      if (!exists) {
        throw const AppError(message: 'File not found', code: 'FILE_NOT_FOUND');
      }

      final bytes = await file.readAsBytes();
      final contentType =
          lookupMimeType(file.path) ?? 'application/octet-stream';

      final response = await http
          .put(
            Uri.parse(url),
            body: bytes,
            headers: {'Content-Type': contentType},
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        throw AppError(
          message: 'File upload failed with status ${response.statusCode}',
          code: 'UPLOAD_FAILED',
        );
      }
    } on TimeoutException catch (_) {
      throw const AppError(
        message: 'Upload timed out after 60 seconds',
        code: 'UPLOAD_TIMEOUT',
      );
    } on SocketException catch (_) {
      throw const AppError(
        message: 'Network error during upload',
        code: 'NETWORK_ERROR',
      );
    } on HttpException catch (e) {
      throw AppError(message: 'HTTP error: ${e.message}', code: 'HTTP_ERROR');
    } on FileSystemException catch (e) {
      throw AppError(
        message: 'Failed to read file: ${e.message}',
        code: 'FILE_READ_ERROR',
      );
    } catch (e) {
      if (e is AppError) rethrow;
      throw AppError(message: 'Upload failed: $e', code: 'UPLOAD_ERROR',
      );
    }
  }
}
