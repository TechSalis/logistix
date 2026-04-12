import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/definitions/usecase.dart';
import 'package:shared/shared.dart';

class LogoutUseCase extends ResultUseCase<AppError, void> {
  const LogoutUseCase({
    required PushNotificationService pushNotificationService,
    required AppRepository appRepository,
    required AuthStatusRepository authStatusRepository,
  })  : _pushNotificationService = pushNotificationService,
        _appRepository = appRepository,
        _authStatusRepository = authStatusRepository;

  final PushNotificationService _pushNotificationService;
  final AppRepository _appRepository;
  final AuthStatusRepository _authStatusRepository;

  @override
  Future<Result<AppError, void>> call() async {
    try {
      await Future.wait([
        // 1. Attempt remote logout (best effort)
        _appRepository.logout(),

        // 2. Delete FCM token locally
        _pushNotificationService.deleteToken(),
      ]);

      // 3. Finalize state change
      _authStatusRepository.setUnauthenticated();
      
      return const Result.data(null);
    } catch (e) {
      _authStatusRepository.setUnauthenticated();
      return Result.error(ErrorHandler.fromException(e));
    }
  }
}
