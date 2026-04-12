import 'package:rider/src/data/dtos/rider_heartbeat_request.dart';
import 'package:rider/src/data/dtos/rider_sync_dto.dart';
import 'package:rider/src/data/dtos/rider_sync_request.dart';
import 'package:rider/src/features/orders/data/dtos/rider_metrics_dto.dart';
import 'package:rider/src/features/orders/data/dtos/update_order_status_request.dart';
import 'package:shared/shared.dart';

abstract class RiderRemoteDataSource {

  Future<OrderDto> updateOrderStatus(UpdateOrderStatusRequest request);

  Future<RiderDto> sendHeartbeat(RiderHeartbeatRequest request);

  Future<RiderSyncDto> syncData(RiderSyncRequest request);

  Future<SyncManager> subscribeToAssignmentUpdates({
    required void Function(
      String eventType,
      OrderDto? order,
      RiderDto? rider,
      RiderMetricsDto? metrics,
    )
    onData,
    required Future<void> Function() onSync,
  });

  Future<RiderDto> fetchProfile();
}

class RiderRemoteDataSourceImpl extends BaseRemoteDataSource
    implements RiderRemoteDataSource {
  RiderRemoteDataSourceImpl(super.gqlService, this.syncManager);

  final SyncManager syncManager;

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
  Future<OrderDto> updateOrderStatus(UpdateOrderStatusRequest request) async {
    final result = await gqlService.mutate<Map<String, dynamic>>(
      '''
      mutation UpdateOrderStatus(\$orderId: ID!, \$status: String!, \$sessionId: String) {
        updateOrderStatus(orderId: \$orderId, status: \$status, sessionId: \$sessionId) {
          ${GqlFragments.orderFields}
        }
      }
    ''',
      variables: {
        ...request.toJson(),
        if (request.sessionId == null)
          'sessionId': await gqlService.sessionId,
      },
    );

    result.throwIfException();
    return OrderDto.fromJson(
      result.data!['updateOrderStatus'] as Map<String, dynamic>,
    );
  }

  @override
  Future<RiderDto> sendHeartbeat(RiderHeartbeatRequest request) async {
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
      variables: request.toJson(),
    );

    return RiderDto.fromJson(data);
  }

  @override
  Future<RiderSyncDto> syncData(RiderSyncRequest request) async {
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
      variables: request.toJson(),
      key: 'riderSync',
    );

    return RiderSyncDto.fromJson(data);
  }

  @override
  Future<SyncManager> subscribeToAssignmentUpdates({
    required void Function(
      String eventType,
      OrderDto? order,
      RiderDto? rider,
      RiderMetricsDto? metrics,
    )
    onData,
    required Future<void> Function() onSync,
  }) async {
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
          eventType,
          orderData != null ? OrderDto.fromJson(orderData) : null,
          riderData != null ? RiderDto.fromJson(riderData) : null,
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
