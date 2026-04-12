import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

/// Repository for app operations
abstract class AppRepository {
  /// Get the current authenticated user
  Future<Result<AppError, User?>> getCurrentUser();

  /// Update the FCM token for the current user
  Future<Result<AppError, void>> updateFcmToken(String token);

  /// Logout from backend
  Future<Result<AppError, void>> logout();
}
