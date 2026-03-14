import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/definitions/usecase.dart';
import 'package:shared/src/domain/use_cases/clear_app_data_use_case.dart';

class LogoutUseCase extends ResultUseCase<AppError, void> {
  const LogoutUseCase(this._clearAppDataUseCase);

  final ClearAppDataUseCase _clearAppDataUseCase;

  @override
  Future<Result<AppError, void>> call() async {
    // Perform any extra logout operations if needed (e.g. telling backend to invalidate token)
    return _clearAppDataUseCase();
  }
}
