import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

/// DeleteAccountUseCase
/// Permanently deletes the user account and all associated data immediately.
class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository, this._logoutUseCase);

  final AuthRepository _repository;
  final LogoutUseCase _logoutUseCase;

  Future<Result<AppError, void>> call() async {
    try {
      final result = await _repository.deleteAccount();

      var failed = false;
      AppError? appError;

      result.when(
        error: (error) {
          failed = true;
          appError = error;
        },
      );

      if (failed) return Result.error(appError!);

      // Account deleted on server — sign out locally.
      await _logoutUseCase();
      return const Result.data(null);
    } catch (e) {
      return Result.error(ErrorHandler.fromException(e));
    }
  }
}
