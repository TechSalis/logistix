// ignore_for_file: experimental_member_use
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/definitions/usecase.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:shared/shared.dart';

class ClearAppDataUseCase extends ResultUseCase<Object, void> {
  const ClearAppDataUseCase(
    this._tokenStore,
    this._userStore,
    this._graphQLService,
    this._logistixDatabase,
  );

  final TokenStore _tokenStore;
  final UserStore _userStore;
  final LogistixDatabase _logistixDatabase;
  final GraphQLService _graphQLService;

  @override
  Future<Result<Object, void>> call() async {
    return await Result.tryCatch<Object, void>(() async {
      await _tokenStore.delete();
      await _userStore.clearUser();
      await _logistixDatabase.clearAllData();
      await _graphQLService.client.resetStore(refetchQueries: false);
    });
  }
}
