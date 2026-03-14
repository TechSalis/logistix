import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:onboarding/src/data/models/dispatcher_profile_dto.dart';
import 'package:onboarding/src/data/models/rider_profile_dto.dart';

abstract class OnboardingRepository {
  Future<Result<AppError, void>> submitRiderProfile(RiderProfileDto profile);
  Future<Result<AppError, void>> submitDispatcherProfile(
    DispatcherProfileDto profile,
  );
}
