import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

/// Repository for app startup operations
abstract class StartupRepository {
  /// Get the current authenticated user
  Future<Result<AppError, User?>> getCurrentUser();
}
