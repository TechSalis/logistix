import 'package:rider/src/data/dtos/rider_heartbeat_request.dart';
import 'package:rider/src/data/dtos/rider_sync_dto.dart';
import 'package:rider/src/data/dtos/rider_sync_request.dart';
import 'package:rider/src/features/deliveries/data/dtos/rider_metrics_dto.dart';
import 'package:rider/src/features/deliveries/data/dtos/update_delivery_status_request.dart';
import 'package:shared/shared.dart';

abstract class RiderRemoteDataSource {

  Future<DeliveryDto> updateDeliveryStatus(UpdateDeliveryStatusRequest request);

  Future<RiderDto> sendHeartbeat(RiderHeartbeatRequest request);

  Future<RiderSyncDto> syncData(RiderSyncRequest request);

  Future<SyncManager> subscribeToAssignmentUpdates({
    required void Function(
      String eventType,
      DeliveryDto? delivery,
      RiderDto? rider,
      RiderMetricsDto? metrics,
    )
    onData,
    required Future<void> Function() onSync,
  });

  Future<String> generatePresignedUploadUrl(String deliveryId);

  Future<RiderDto> fetchProfile();
}

class RiderRemoteDataSourceImpl extends BaseRemoteDataSource
    implements RiderRemoteDataSource {
  RiderRemoteDataSourceImpl(super.gqlService, this.syncManager);

  final SyncManager syncManager;

  @override
  Future<String> generatePresignedUploadUrl(String deliveryId) async {
    const mutation = r'''
      mutation GeneratePresignedUploadUrl($deliveryId: ID!) {
        generatePresignedUploadUrl(deliveryId: $deliveryId)
      }
    ''';

    final data = await mutate<String>(
      mutation,
      key: 'generatePresignedUploadUrl',
      variables: {'deliveryId': deliveryId},
    );

    return data;
  }

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
  Future<DeliveryDto> updateDeliveryStatus(UpdateDeliveryStatusRequest request) async {
    final result = await gqlService.mutate<Map<String, dynamic>>(
      '''
      mutation UpdateDeliveryStatus(\$deliveryId: ID!, \$status: String!, \$sessionId: String, \$pin: String, \$proofImageUrl: String) {
        updateDeliveryStatus(deliveryId: \$deliveryId, status: \$status, sessionId: \$sessionId, verificationPin: \$pin, proofImageUrl: \$proofImageUrl) {
          ${GqlFragments.deliveryFields}
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
    return DeliveryDto.fromJson(
      result.data!['updateDeliveryStatus'] as Map<String, dynamic>,
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
          deliveries {
            ${GqlFragments.deliveryFields}
          }
          rider {
            ${GqlFragments.riderFields}
          }
          metrics {
            ${GqlFragments.riderMetricsFields}
          }
          deletedDeliveryIds
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
      DeliveryDto? delivery,
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
        final deliveryData = updateData['delivery'] as Map<String, dynamic>?;
        final riderData = updateData['rider'] as Map<String, dynamic>?;
        final eventType = updateData['eventType'] as String;
        final metricsData = updateData['metrics'] as Map<String, dynamic>?;

        onData(
          eventType,
          deliveryData != null ? DeliveryDto.fromJson(deliveryData) : null,
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
        delivery {
          ${GqlFragments.deliveryFields}
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
