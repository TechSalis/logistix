import 'package:rider/src/data/dtos/rider_sync_dto.dart';
import 'package:shared/shared.dart';

abstract class RiderRemoteDataSource {

  Future<OrderDto> updateOrderStatus(String orderId, String status);

  Future<RiderDto> sendHeartbeat({
    double? lat,
    double? lng,
    int? batteryLevel,
  });

  Future<RiderSyncDto> syncData({double? since, int? limit, int? offset});

  Future<SyncManager> subscribeToAssignmentUpdates({
    required void Function(
      OrderDto? order,
      RiderDto? rider,
      String eventType,
      RiderMetricsDto? metrics,
    )
    onData,
    required Future<void> Function() onSync,
  });

  Future<RiderDto> fetchProfile();
}

class RiderRemoteDataSourceImpl extends BaseRemoteDataSource
    implements RiderRemoteDataSource {
  RiderRemoteDataSourceImpl(super.gqlService);

  @override
  Future<RiderDto> fetchProfile() async {
    const queryDocument =
        '''
      query MeRider {
        meRider {
          ${GqlFragments.riderFields}
        }
      }
    ''';

    final data = await query<Map<String, dynamic>>(
      queryDocument,
      key: 'meRider',
    );

    return RiderDto.fromJson(data);
  }

  @override
  Future<OrderDto> updateOrderStatus(String orderId, String status) async {
    final result = await gqlService.mutate<Map<String, dynamic>>(
      '''
      mutation UpdateOrderStatus(\$orderId: ID!, \$status: String!, \$sessionId: String) {
        updateOrderStatus(orderId: \$orderId, status: \$status, sessionId: \$sessionId) {
          ${GqlFragments.orderFields}
        }
      }
    ''',
      variables: {
        'orderId': orderId,
        'status': status,
        'sessionId': await gqlService.sessionId,
      },
    );

    result.throwIfException();
    return OrderDto.fromJson(
      result.data!['updateOrderStatus'] as Map<String, dynamic>,
    );
  }

  @override
  Future<RiderDto> sendHeartbeat({
    double? lat,
    double? lng,
    int? batteryLevel,
  }) async {
    const mutation =
        '''
      mutation RiderHeartbeat(\$lat: Float, \$lng: Float, \$batteryLevel: Int) {
        riderHeartbeat(lat: \$lat, lng: \$lng, batteryLevel: \$batteryLevel) {
          ${GqlFragments.riderFields}
        }
      }
    ''';

    final data = await mutate<Map<String, dynamic>>(
      mutation,
      key: 'riderHeartbeat',
      variables: {'lat': lat, 'lng': lng, 'batteryLevel': batteryLevel},
    );

    return RiderDto.fromJson(data);
  }

  @override
  Future<RiderSyncDto> syncData({
    double? since,
    int? limit,
    int? offset,
  }) async {
    const queryDocument = '''
      query RiderSync(\$since: Float, \$limit: Int, \$offset: Int) {
        riderSync(since: \$since, limit: \$limit, offset: \$offset) {
          orders {
            ${GqlFragments.orderFields}
          }
          rider {
            ${GqlFragments.riderFields}
          }
          metrics {
            ${GqlFragments.riderMetricsFields}
          }
          deletedOrderIds
          lastUpdated
        }
      }
    ''';

    final data = await query<Map<String, dynamic>>(
      queryDocument,
      variables: {'since': since, 'limit': limit, 'offset': offset},
      key: 'riderSync',
    );

    return RiderSyncDto.fromJson(data);
  }

  @override
  Future<SyncManager> subscribeToAssignmentUpdates({
    required void Function(
      OrderDto? order,
      RiderDto? rider,
      String eventType,
      RiderMetricsDto? metrics,
    )
    onData,
    required Future<void> Function() onSync,
  }) async {
    final syncManager = SyncManager(gqlService);
    await syncManager.startSubscription(
      subscriptionDocument: _riderAssignmentUpdatedSubscription,
      variables: {'sessionId': await gqlService.sessionId},
      onData: (data) async {
        final updateData =
            data['riderAssignmentUpdated'] as Map<String, dynamic>;
        final orderData = updateData['order'] as Map<String, dynamic>?;
        final riderData = updateData['rider'] as Map<String, dynamic>?;
        final eventType = updateData['eventType'] as String;
        final metricsData = updateData['metrics'] as Map<String, dynamic>?;

        onData(
          orderData != null ? OrderDto.fromJson(orderData) : null,
          riderData != null ? RiderDto.fromJson(riderData) : null,
          eventType,
          metricsData != null ? RiderMetricsDto.fromJson(metricsData) : null,
        );
      },
      onSync: onSync,
    );
    return syncManager;
  }

  static const String _riderAssignmentUpdatedSubscription =
      '''
    subscription RiderAssignmentUpdated(\$sessionId: String) {
      riderAssignmentUpdated(sessionId: \$sessionId) {
        order {
          ${GqlFragments.orderFields}
        }
        rider {
          ${GqlFragments.riderFields}
        }
        eventType
        metrics {
          ${GqlFragments.riderMetricsFields}
        }
      }
    }
  ''';
}
