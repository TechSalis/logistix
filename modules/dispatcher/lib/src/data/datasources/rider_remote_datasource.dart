import 'package:bootstrap/definitions/app_error.dart';
import 'package:shared/shared.dart';

abstract class RiderRemoteDataSource {
  Future<List<RiderDto>> getPendingRiders();
  Future<List<RiderDto>> getRiders({String? search, int? limit, int? offset});
  Future<List<RiderLocationInfoDto>> getRiderLocations();
  Future<void> acceptRider(String riderId);
  Future<void> rejectRider(String riderId);
  Future<RiderDto> getRider(String id);
}

const _riderLocationFragment = '''
  fragment RiderLocationFields on Rider {
    id
    fullName
    email
    status
    phoneNumber
    companyId
    lastLat
    lastLng
    batteryLevel
    isAccepted
    isIndependent
    permitUrl
    createdAt
    updatedAt
  }
''';

const _riderFragment = '''
  fragment RiderFields on Rider {
    id
    fullName
    email
    status
    phoneNumber
    companyId
    lastLat
    lastLng
    batteryLevel
    isAccepted
    isIndependent
    permitUrl
    createdAt
    updatedAt
    activeOrder {
      id
      trackingNumber
      status
      pickupAddress
      dropOffAddress
      description
      customerPhone
      codAmount
      createdAt
    }
  }
''';

class RiderRemoteDataSourceImpl implements RiderRemoteDataSource {
  RiderRemoteDataSourceImpl(this._gqlService);
  final GraphQLService _gqlService;

  @override
  Future<List<RiderDto>> getPendingRiders() async {
    const query =
        '''
      query GetPendingRiders {
        pendingRiders {
          ...RiderFields
        }
      }
      $_riderFragment
    ''';

    final result = await _gqlService.query(query);
    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['pendingRiders'] as List?;
    if (data == null) return [];

    return data
        .map((json) => RiderDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RiderDto>> getRiders({
    String? search,
    int? limit,
    int? offset,
  }) async {
    const query =
        '''
      query GetRiders(\$search: String, \$limit: Int, \$offset: Int) {
        riders(search: \$search, limit: \$limit, offset: \$offset) {
          ...RiderFields
        }
      }
      $_riderFragment
    ''';

    final result = await _gqlService.query(
      query,
      variables: {'search': search, 'limit': limit, 'offset': offset},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['riders'] as List?;
    if (data == null) return [];

    return data
        .map((json) => RiderDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<RiderLocationInfoDto>> getRiderLocations() async {
    const query =
        '''
      query GetRiderLocations {
        riders(limit: 1000) {
          ...RiderLocationFields
        }
      }
      $_riderLocationFragment
    ''';

    final result = await _gqlService.query(query);

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['riders'] as List?;
    if (data == null) return [];

    return data
        .map(
          (json) => RiderLocationInfoDto.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> acceptRider(String riderId) async {
    const mutation = r'''
      mutation AcceptRider($riderId: ID!) {
        acceptRider(riderId: $riderId) {
          id
        }
      }
    ''';

    final result = await _gqlService.mutate(
      mutation,
      variables: {'riderId': riderId},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }
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

    final result = await _gqlService.mutate(
      mutation,
      variables: {'riderId': riderId},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }
  }

  @override
  Future<RiderDto> getRider(String id) async {
    const query =
        '''
      query GetRider(\$id: ID!) {
        rider(id: \$id) {
          ...RiderFields
        }
      }
      $_riderFragment
    ''';
    final result = await _gqlService.query(query, variables: {'id': id});
    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['rider'];
    if (data == null) throw const UserError(message: 'Rider not found');

    return RiderDto.fromJson(data as Map<String, dynamic>);
  }
}
