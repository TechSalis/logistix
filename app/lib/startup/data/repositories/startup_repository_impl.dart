import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:logistix/startup/data/datasources/startup_remote_datasource.dart';
import 'package:logistix/startup/domain/repositories/startup_repository.dart';
import 'package:shared/shared.dart';

class StartupRepositoryImpl implements StartupRepository {
  const StartupRepositoryImpl(this._dataSource, this._tokenStore);
  final TokenStore _tokenStore;
  final StartupRemoteDataSource _dataSource;

  @override
  Future<Result<AppError, User?>> getCurrentUser() async {
    final token = await _tokenStore.read();
    if (token == null) return const Result.data(null);

    return Result.tryCatch<AppError, User?>(() async {
      final userDto = await _dataSource.getCurrentUser();
      return userDto?.toEntity();
    });
  }
}
