import 'package:bootstrap/definitions/app_error.dart';
import 'package:onboarding/src/data/models/dispatcher_profile_dto.dart';
import 'package:onboarding/src/data/models/rider_profile_dto.dart';
import 'package:shared/shared.dart';

/// Remote data source for onboarding operations
abstract class OnboardingRemoteDataSource {
  /// Submit rider profile
  Future<void> submitRiderProfile(RiderProfileDto profile);

  /// Submit dispatcher profile
  Future<void> submitDispatcherProfile(DispatcherProfileDto profile);
}

class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  OnboardingRemoteDataSourceImpl(this._graphql);
  final GraphQLService _graphql;

  @override
  Future<void> submitRiderProfile(RiderProfileDto profile) async {
    try {
      const mutation = r'''
        mutation SubmitRiderProfile(
          $phoneNumber: String!
          $registrationNumber: String!
          $companyId: ID
          $isIndependent: Boolean
          $permitUrl: String
        ) {
          submitRiderProfile(
            input: {
              phoneNumber: $phoneNumber
              registrationNumber: $registrationNumber
              companyId: $companyId
              isIndependent: $isIndependent
              permitUrl: $permitUrl
            }
          ) {
            success
          }
        }
      ''';

      final result = await _graphql.mutate(
        mutation,
        variables: {
          'phoneNumber': profile.phoneNumber,
          'registrationNumber': profile.registrationNumber,
          'companyId': profile.companyId,
          'isIndependent': profile.isIndependent,
          'permitUrl': profile.permitUrl,
        },
      );

      if (result.hasException) {
        throw ErrorHandler.fromException(result.exception);
      }
    } catch (e) {
      if (e is AppError) rethrow;
      throw ErrorHandler.fromException(e);
    }
  }

  @override
  Future<void> submitDispatcherProfile(DispatcherProfileDto profile) async {
    try {
      const mutation = r'''
        mutation SubmitDispatcherProfile(
          $companyName: String!
          $phoneNumber: String!
          $address: String!
          $cac: String!
        ) {
          submitDispatcherProfile(
            input: {
              companyName: $companyName
              phoneNumber: $phoneNumber
              address: $address
              cac: $cac
            }
          ) {
            success
          }
        }
      ''';

      final result = await _graphql.mutate(
        mutation,
        variables: {
          'companyName': profile.companyName,
          'phoneNumber': profile.phoneNumber,
          'address': profile.address,
          'cac': profile.cac,
        },
      );

      if (result.hasException) {
        throw ErrorHandler.fromException(result.exception);
      }
    } catch (e) {
      if (e is AppError) rethrow;
      throw ErrorHandler.fromException(e);
    }
  }
}
