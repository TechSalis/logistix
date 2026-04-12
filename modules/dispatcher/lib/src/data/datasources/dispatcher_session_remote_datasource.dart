import 'dart:async';

import 'package:dispatcher/src/data/dtos/dispatcher_sync_dto.dart';
import 'package:dispatcher/src/data/dtos/dispatcher_sync_request.dart';
import 'package:dispatcher/src/features/orders/data/dtos/dispatcher_metrics_dto.dart';
import 'package:shared/shared.dart';

abstract class DispatcherSessionRemoteDataSource {
  Future<DispatcherSyncDto> syncData(DispatcherSyncRequest request);

  Future<SyncManager> subscribeToOrderUpdates({
    required void Function(
      OrderDto order,
      String eventType,
      DispatcherMetricsDto? metrics,
    )
    onData,
    required Future<void> Function() onSync,
  });

  Future<SyncManager> subscribeToRiderUpdates({
    required void Function(
      RiderDto rider,
      String eventType,
      DispatcherMetricsDto? metrics,
    )
    onData,
    Future<void> Function()? onSync,
  });
}

class DispatcherSessionRemoteDataSourceImpl extends BaseRemoteDataSource
    implements DispatcherSessionRemoteDataSource {
  DispatcherSessionRemoteDataSourceImpl(
    super.gqlService, 
    this.syncManager,
  );

  final SyncManager syncManager;

  @override
  Future<DispatcherSyncDto> syncData(DispatcherSyncRequest request) async {
    const queryDocument =
        '''
      query DispatcherSync(\$since: Float, \$limit: Int, \$offset: Int) {
        dispatcherSync(since: \$since, limit: \$limit, offset: \$offset) {
          orders {
            ${GqlFragments.orderFields}
          }
          riders {
            ${GqlFragments.riderFields}
          }
          metrics {
            ${GqlFragments.dispatcherMetricsFields}
          }
          deletedOrderIds
          deletedRiderIds
          lastUpdated
        }
      }
    ''';

    final data = await query<Map<String, dynamic>>(
      queryDocument,
      variables: request.toJson(),
      key: 'dispatcherSync',
    );

    return DispatcherSyncDto.fromJson(data);
  }

  @override
  Future<SyncManager> subscribeToOrderUpdates({
    required void Function(
      OrderDto order,
      String eventType,
      DispatcherMetricsDto? metrics,
    )
    onData,
    required Future<void> Function() onSync,
  }) async {
    // Uses the injected syncManager
    await syncManager.startSubscription(
      subscriptionDocument: _orderSubscription,
      variables: {
        'sessionId': await gqlService.sessionId,
      },
      onData: (data) async {
        final updateData = data['orderUpdated'] as Map<String, dynamic>;
        final orderData = updateData['order'] as Map<String, dynamic>;
        final orderDto = OrderDto.fromJson(orderData);
        final eventType = updateData['eventType'] as String;
        final metricsData = updateData['metrics'] as Map<String, dynamic>?;
        final metrics = metricsData != null
            ? DispatcherMetricsDto.fromJson(metricsData)
            : null;
        onData(orderDto, eventType, metrics);
      },
      onSync: onSync,
    );

    return syncManager;
  }

  @override
  Future<SyncManager> subscribeToRiderUpdates({
    required void Function(
      RiderDto rider,
      String eventType,
      DispatcherMetricsDto? metrics,
    )
    onData,
    Future<void> Function()? onSync,
  }) async {
    // Uses the same injected syncManager, which now supports multiple subscriptions
    await syncManager.startSubscription(
      subscriptionDocument: _riderSubscription,
      variables: {
        'sessionId': await gqlService.sessionId,
      },
      onData: (data) async {
        final updateData = data['riderUpdated'] as Map<String, dynamic>;
        final riderData = updateData['rider'] as Map<String, dynamic>;
        final riderDto = RiderDto.fromJson(riderData);
        final eventType = updateData['eventType'] as String;
        final metricsData = updateData['metrics'] as Map<String, dynamic>?;
        final metrics = metricsData != null
            ? DispatcherMetricsDto.fromJson(metricsData)
            : null;
        onData(riderDto, eventType, metrics);
      },
      onSync: onSync,
    );

    return syncManager;
  }

  static const String _orderSubscription =
      '''
    subscription OrderUpdated(\$sessionId: String) {
      orderUpdated(sessionId: \$sessionId) {
        order {
          ${GqlFragments.orderFields}
        }
        eventType
        metrics {
          ${GqlFragments.dispatcherMetricsFields}
        }
      }
    }
  ''';

  static const String _riderSubscription =
      '''
    subscription RiderUpdated(\$sessionId: String) {
      riderUpdated(sessionId: \$sessionId) {
        rider {
          ${GqlFragments.riderFields}
        }
        eventType
        metrics {
          ${GqlFragments.dispatcherMetricsFields}
        }
      }
    }
  ''';
}
