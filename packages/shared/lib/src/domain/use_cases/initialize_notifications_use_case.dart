import 'dart:async';
import 'package:adapters/adapters.dart';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/definitions/usecase.dart';
import 'package:shared/shared.dart';

/// Use case to initialize push notifications and sync the device token with the backend.
///
/// Refined to return the [StreamSubscription] for the token refresh listener
/// to ensure proper lifecycle management and prevent memory leaks on logout.
class InitializeNotificationsUseCase
    extends ResultUseCase<AppError, StreamSubscription<String>?> {
  const InitializeNotificationsUseCase(
    this._notificationService,
    this._appRepository,
  );

  final PushNotificationService _notificationService;
  final AppRepository _appRepository;

  @override
  Future<Result<AppError, StreamSubscription<String>?>> call() async {
    try {
      // 1. Initialize local notification engine
      await _notificationService.init();

      // 2. Fetch and upload FCM token to match physical device with user session
      final token = await _notificationService.getFirebaseToken();
      if (token != null) {
        await _appRepository.updateFcmToken(token);
        appLogger.debug('FCM token synchronized with backend.');
      }

      // 3. Listen for future token refreshes (rotation)
      // ignore: cancel_subscriptions
      final subscription = _notificationService.onTokenRefresh.listen((
        newToken,
      ) {
        _appRepository.updateFcmToken(newToken).catchError((Object e) {
          appLogger.error('Failed to sync refreshed FCM token: $e');
          return const Result<AppError, void>.data(null);
        });
      });
      return Result.data(subscription);
    } catch (e) {
      appLogger.error('Failed to initialize notifications: $e');
      return Result.error(ErrorHandler.fromException(e));
    }
  }
}
