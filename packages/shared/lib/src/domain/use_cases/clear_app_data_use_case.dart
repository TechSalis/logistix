import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/definitions/usecase.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:shared/shared.dart';

class ClearAppDataUseCase extends ResultUseCase<AppError, void> {
  const ClearAppDataUseCase(
    this._tokenStore,
    this._userStore,
    this._graphQLService,
  );

  final TokenStore _tokenStore;
  final UserStore _userStore;
  final GraphQLService _graphQLService;

  @override
  Future<Result<AppError, void>> call() async {
    return await Result.tryCatch<AppError, void>(() async {
      await Future.wait<void>([
        _tokenStore.delete(),
        _userStore.clearUser(),
        HydratedBloc.storage.clear(),
      ]);
      await _graphQLService.client.resetStore();
    });
  }
}
