import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:onboarding/src/data/datasources/onboarding_remote_datasource.dart';
import 'package:onboarding/src/data/models/dispatcher_profile_dto.dart';
import 'package:onboarding/src/data/models/rider_profile_dto.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:onboarding/src/domain/repositories/onboarding_repository.dart';
import 'package:shared/shared.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._dataSource, this._tokenStore, this._userStore);
  final OnboardingRemoteDataSource _dataSource;
  final TokenStore _tokenStore;
  final UserStore _userStore;

  @override
  Future<Result<AppError, User>> submitRiderProfile(
    RiderProfileDto profile,
  ) async {
    return Result.tryCatch<AppError, User>(() async {
      final (token, userDto) = await _dataSource.submitRiderProfile(profile);
      await _tokenStore.write(token);
      final user = userDto.toEntity();
      await _userStore.saveUser(user);
      return user;
    });
  }

  @override
  Future<Result<AppError, User>> submitDispatcherProfile(
    DispatcherProfileDto profile,
  ) async {
    return Result.tryCatch<AppError, User>(() async {
      final (token, userDto) = await _dataSource.submitDispatcherProfile(profile);
      await _tokenStore.write(token);
      final user = userDto.toEntity();
      await _userStore.saveUser(user);
      return user;
    });
  }
}
