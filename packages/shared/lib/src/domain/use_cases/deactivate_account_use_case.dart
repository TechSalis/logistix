import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

/// DeactivateAccountUseCase
/// Marks the user account as deactivated.
/// It will be permanently removed if the user does not login within 30 days.
class DeactivateAccountUseCase {
  const DeactivateAccountUseCase(this._repository, this._logoutUseCase);

  final AuthRepository _repository;
  final LogoutUseCase _logoutUseCase;

  Future<Result<AppError, void>> call() async {
    try {
      final result = await _repository.deactivateAccount();

      var failed = false;
      AppError? appError;

      result.when(
        error: (error) {
          failed = true;
          appError = error;
        },
      );

      if (failed) return Result.error(appError!);

      // Successfully deactivated on server, now sign out locally.
      await _logoutUseCase();
      return const Result.data(null);
    } catch (e) {
      return Result.error(ErrorHandler.fromException(e));
    }
  }
}
