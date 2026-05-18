import 'package:customer/src/data/dtos/customer_delivery_input.dart';
import 'package:customer/src/data/dtos/customer_sync_dto.dart';
import 'package:shared/shared.dart';

abstract class CustomerDeliveryRemoteDataSource {
  Future<DeliveryDto> createDelivery(CustomerDeliveryInput input);
  Future<DeliveryDto> getDelivery(String id);

  Future<CustomerSyncDto> syncData({
    double? since,
    int? limit,
    int? offset,
  });

  Future<SyncManager> subscribeToUpdates({
    required void Function(DeliveryDto delivery, SubscriptionEventType eventType)
        onData,
    Future<void> Function()? onSync,
  });
}

class CustomerDeliveryRemoteDataSourceImpl extends BaseRemoteDataSource
    implements CustomerDeliveryRemoteDataSource {
  CustomerDeliveryRemoteDataSourceImpl(super.gqlService, this.syncManager);

  final SyncManager syncManager;

  @override
  Future<DeliveryDto> createDelivery(CustomerDeliveryInput input) async {
    final data = await mutate<Map<String, dynamic>>(
      '''
      mutation CreateCustomerDelivery(\$delivery: DeliveryCreateInput!, \$sessionId: String) {
        createDelivery(delivery: \$delivery, sessionId: \$sessionId) {
          ${GqlFragments.deliveryFields}
        }
      }
      ''',
      key: 'createDelivery',
      variables: {
        'delivery': input.toJson(),
        'sessionId': await gqlService.sessionId,
      },
    );

    return DeliveryDto.fromJson(data);
  }

  @override
  Future<DeliveryDto> getDelivery(String id) async {
    final data = await query<Map<String, dynamic>>(
      '''
      query GetDelivery(\$id: ID!) {
        delivery(id: \$id) {
          ${GqlFragments.deliveryFields}
        }
      }
      ''',
      key: 'delivery',
      variables: {'id': id},
    );

    return DeliveryDto.fromJson(data);
  }

  @override
  Future<CustomerSyncDto> syncData({
    double? since,
    int? limit,
    int? offset,
  }) async {
    final data = await query<Map<String, dynamic>>(
      '''
      query CustomerSync(\$since: Float, \$limit: Int, \$offset: Int) {
        customerSync(since: \$since, limit: \$limit, offset: \$offset) {
          deliveries {
            ${GqlFragments.deliveryFields}
          }
          deletedDeliveryIds
          lastUpdated
        }
      }
      ''',
      key: 'customerSync',
      variables: {
        'since': since,
        'limit': limit,
        'offset': offset,
      },
    );

    return CustomerSyncDto.fromJson(data);
  }

  @override
  Future<SyncManager> subscribeToUpdates({
    required void Function(DeliveryDto delivery, SubscriptionEventType eventType)
        onData,
    Future<void> Function()? onSync,
  }) async {
    await syncManager.startSubscription(
      subscriptionDocument: '''
      subscription OnCustomerDeliveryUpdated(\$sessionId: String) {
        customerDeliveryUpdated(sessionId: \$sessionId) {
          delivery {
            ${GqlFragments.deliveryFields}
          }
          eventType
        }
      }
      ''',
      variables: {
        'sessionId': await gqlService.sessionId,
      },
      onData: (data) async {
        final payload = data['customerDeliveryUpdated'] as Map<String, dynamic>;
        final delivery =
            DeliveryDto.fromJson(payload['delivery'] as Map<String, dynamic>);
        final eventType = SubscriptionEventType.values.byName(
          (payload['eventType'] as String).toLowerCase(),
        );
        onData(delivery, eventType);
      },
      onSync: onSync,
    );
    return syncManager;
  }
}
