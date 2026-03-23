import 'package:bootstrap/definitions/app_error.dart';
import 'package:shared/shared.dart';

abstract class RiderRemoteDataSource {
  Future<RiderDto> acceptRider(String riderId);
  Future<void> rejectRider(String riderId);
}

class RiderRemoteDataSourceImpl implements RiderRemoteDataSource {
  RiderRemoteDataSourceImpl(this._gqlService);
  final GraphQLService _gqlService;

  @override
  Future<RiderDto> acceptRider(String riderId) async {
    const mutation = r'''
      mutation AcceptRider($riderId: ID!) {
        acceptRider(riderId: $riderId) {
          id
          fullName
          email
          companyId
          status
          lastLat
          lastLng
          batteryLevel
          isAccepted
          permitStatus
          phoneNumber
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await _gqlService.mutate<Map<String, dynamic>>(
      mutation,
      variables: {'riderId': riderId},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['acceptRider'] as Map<String, dynamic>?;
    if (data == null) {
      throw const UserError(message: 'Failed to accept rider');
    }

    return RiderDto.fromJson(data);
  }

  @override
  Future<void> rejectRider(String riderId) async {
    const mutation = r'''
      mutation RejectRider($riderId: ID!) {
        rejectRider(riderId: $riderId) {
          id
        }
      }
    ''';

    final result = await _gqlService.mutate<Map<String, dynamic>>(
      mutation,
      variables: {'riderId': riderId},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }
  }
}
