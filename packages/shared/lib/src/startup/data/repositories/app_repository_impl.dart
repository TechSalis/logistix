import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:shared/shared.dart';

class AppRepositoryImpl implements AppRepository {
  const AppRepositoryImpl(
    this._dataSource,
    this._tokenStore,
    this._userStore,
  );

  final TokenStore _tokenStore;
  final UserStore _userStore;
  final AppRemoteDataSource _dataSource;


  @override
  Future<Result<AppError, User?>> getCurrentUser() async {
    final token = await _tokenStore.read();
    if (token == null) return const Result.data(null);

    return Result.tryCatch<AppError, User?>(() async {
      try {
        final userDto = await _dataSource.getCurrentUser();
        if (userDto != null) {
          final userEntity = userDto.toEntity();
          await _userStore.saveUser(userEntity);
          return userEntity;
        }
        return null;
      } on Object {
        return _userStore.getUser();
      }
    });
  }

  @override
  Future<Result<AppError, void>> updateFcmToken(String token) async {
    return Result.tryCatch<AppError, void>(() async {
      await _dataSource.updateFcmToken(token);
    });
  }

  @override
  Future<Result<AppError, void>> logout() async {
    return Result.tryCatch<AppError, void>(() async {
      await _dataSource.logout();
    });
  }
}
