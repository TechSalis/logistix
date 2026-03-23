import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/definitions/usecase.dart';
import 'package:shared/shared.dart';

class LogoutUseCase extends ResultUseCase<AppError, void> {
  const LogoutUseCase(this._clearAppDataUseCase);

  final ClearAppDataUseCase _clearAppDataUseCase;

  @override
  Future<Result<AppError, void>> call() async {
    final response = await _clearAppDataUseCase();
    return response.map(
      (error) => Result.error(ErrorHandler.fromException(error)),
      (r) => const Result.data(null),
    );
  }
}
