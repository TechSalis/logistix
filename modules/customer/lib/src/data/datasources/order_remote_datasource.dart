import 'package:customer/src/data/dtos/customer_order_input.dart';
import 'package:customer/src/data/dtos/customer_sync_dto.dart';
import 'package:shared/shared.dart';

abstract class CustomerOrderRemoteDataSource {
  Future<OrderDto> createOrder(CustomerOrderInput input);
  Future<OrderDto> getOrder(String id);

  Future<CustomerSyncDto> syncData({
    double? since,
    int? limit,
    int? offset,
  });

  Future<SyncManager> subscribeToUpdates({
    required void Function(OrderDto order, SubscriptionEventType eventType)
        onData,
    Future<void> Function()? onSync,
  });
}

class CustomerOrderRemoteDataSourceImpl extends BaseRemoteDataSource
    implements CustomerOrderRemoteDataSource {
  CustomerOrderRemoteDataSourceImpl(super.gqlService);

  @override
  Future<OrderDto> createOrder(CustomerOrderInput input) async {
    final data = await mutate<Map<String, dynamic>>(
      '''
      mutation CreateCustomerOrder(\$order: OrderCreateInput!, \$sessionId: String) {
        createOrder(order: \$order, sessionId: \$sessionId) {
          ${GqlFragments.orderFields}
        }
      }
      ''',
      key: 'createOrder',
      variables: {
        'order': input.toJson(),
        'sessionId': await gqlService.sessionId,
      },
    );

    return OrderDto.fromJson(data);
  }

  @override
  Future<OrderDto> getOrder(String id) async {
    final data = await query<Map<String, dynamic>>(
      '''
      query GetOrder(\$id: ID!) {
        order(id: \$id) {
          ${GqlFragments.orderFields}
        }
      }
      ''',
      key: 'order',
      variables: {'id': id},
    );

    return OrderDto.fromJson(data);
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
          orders {
            ${GqlFragments.orderFields}
          }
          deletedOrderIds
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
    required void Function(OrderDto order, SubscriptionEventType eventType)
        onData,
    Future<void> Function()? onSync,
  }) async {
    return subscribe(
      '''
      subscription OnCustomerOrderUpdated(\$sessionId: String) {
        customerOrderUpdated(sessionId: \$sessionId) {
          order {
            ${GqlFragments.orderFields}
          }
          eventType
        }
      }
      ''',
      variables: {
        'sessionId': await gqlService.sessionId,
      },
      onData: (Map<String, dynamic> data) {
        final payload = data['customerOrderUpdated'];
        final order =
            OrderDto.fromJson(payload['order'] as Map<String, dynamic>);
        final eventType = SubscriptionEventType.values.byName(
          (payload['eventType'] as String).toLowerCase(),
        );
        onData(order, eventType);
      },
      onSync: onSync,
    );
  }
}
