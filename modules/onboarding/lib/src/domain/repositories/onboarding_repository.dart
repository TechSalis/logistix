import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:onboarding/src/data/models/dispatcher_profile_dto.dart';
import 'package:onboarding/src/data/models/rider_profile_dto.dart';
import 'package:shared/shared.dart';

abstract class OnboardingRepository {
  Future<Result<AppError, User>> submitRiderProfile(RiderProfileDto profile);
  Future<Result<AppError, User>> submitDispatcherProfile(
    DispatcherProfileDto profile,
  );
}
