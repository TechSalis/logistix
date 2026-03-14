import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:onboarding/src/data/datasources/onboarding_remote_datasource.dart';
import 'package:onboarding/src/data/models/dispatcher_profile_dto.dart';
import 'package:onboarding/src/data/models/rider_profile_dto.dart';
import 'package:onboarding/src/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._dataSource);
  final OnboardingRemoteDataSource _dataSource;

  @override
  Future<Result<AppError, void>> submitRiderProfile(
    RiderProfileDto profile,
  ) async {
    return Result.tryCatch<AppError, void>(() async {
      await _dataSource.submitRiderProfile(profile);
    });
  }

  @override
  Future<Result<AppError, void>> submitDispatcherProfile(
    DispatcherProfileDto profile,
  ) async {
    return Result.tryCatch<AppError, void>(() async {
      await _dataSource.submitDispatcherProfile(profile);
    });
  }
}
