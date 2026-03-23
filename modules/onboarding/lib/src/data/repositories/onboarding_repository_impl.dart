import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/interfaces/http/oauth_token/models/oauth_token.dart';
import 'package:bootstrap/interfaces/http/token_store.dart';
import 'package:onboarding/src/data/datasources/onboarding_remote_datasource.dart';
import 'package:onboarding/src/data/models/dispatcher_profile_dto.dart';
import 'package:onboarding/src/data/models/rider_profile_dto.dart';
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
      return _saveResponseAndReturnUser(token, userDto);
    });
  }

  @override
  Future<Result<AppError, User>> submitDispatcherProfile(
    DispatcherProfileDto profile,
  ) async {
    return Result.tryCatch<AppError, User>(() async {
      final (token, userDto) = await _dataSource.submitDispatcherProfile(
        profile,
      );
      return _saveResponseAndReturnUser(token, userDto);
    });
  }

  @override
  Future<Result<AppError, User>> submitCustomerProfile() async {
    return Result.tryCatch<AppError, User>(() async {
      final (token, userDto) = await _dataSource.submitCustomerProfile();
      return _saveResponseAndReturnUser(token, userDto);
    });
  }

  Future<User> _saveResponseAndReturnUser(
    OAuthToken token,
    UserDto userDto,
  ) async {
    final user = userDto.toEntity();
    try {
      await Future.wait([_tokenStore.write(token), _userStore.saveUser(user)]);
      return user;
    } catch (e) {
      await Future.wait([_tokenStore.delete(), _userStore.clearUser()]);
      rethrow;
    }
  }
}
