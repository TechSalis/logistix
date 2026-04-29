import 'package:dispatcher/src/features/orders/data/dtos/assign_order_request.dart';
import 'package:dispatcher/src/features/orders/data/dtos/order_create_input.dart';
import 'package:dispatcher/src/features/orders/data/dtos/update_order_status_request.dart';
import 'package:shared/shared.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderDto>> createBulkOrders(List<OrderCreateInput> orders);
  Future<OrderDto> updateOrderStatus(UpdateOrderStatusRequest request);
  Future<OrderDto> rejectOrder(String orderId);
  Future<OrderDto> assignOrder(AssignOrderRequest request);
  Future<List<OrderCreateInput>> parseTextToOrders(String text);
}

class OrderRemoteDataSourceImpl extends BaseRemoteDataSource
    implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl(super.gqlService);

  @override
  Future<OrderDto> updateOrderStatus(UpdateOrderStatusRequest request) async {
    const mutation =
        '''
      mutation UpdateOrderStatus(\$orderId: ID!, \$status: String!, \$sessionId: String) {
        updateOrderStatus(orderId: \$orderId, status: \$status, sessionId: \$sessionId) {
          ${GqlFragments.orderFields}
        }
      }
    ''';

    final data = await mutate<Map<String, dynamic>>(
      mutation,
      key: 'updateOrderStatus',
      variables: {
        ...request.toJson(),
        if (request.sessionId == null)
          'sessionId': await gqlService.sessionId,
      },
    );

    return OrderDto.fromJson(data);
  }

  @override
  Future<OrderDto> rejectOrder(String orderId) async {
    const mutation =
        '''
      mutation RejectOrder(\$orderId: ID!, \$sessionId: String) {
        rejectOrder(orderId: \$orderId, sessionId: \$sessionId) {
          ${GqlFragments.orderFields}
        }
      }
    ''';

    final data = await mutate<Map<String, dynamic>>(
      mutation,
      key: 'rejectOrder',
      variables: {
        'orderId': orderId,
        'sessionId': await gqlService.sessionId,
      },
    );

    return OrderDto.fromJson(data);
  }

  @override
  Future<OrderDto> assignOrder(AssignOrderRequest request) async {
    const mutation =
        '''
      mutation AssignOrder(\$orderId: ID!, \$riderId: ID!, \$sessionId: String) {
        assignOrder(orderId: \$orderId, riderId: \$riderId, sessionId: \$sessionId) {
          ${GqlFragments.orderFields}
        }
      }
    ''';

    final data = await mutate<Map<String, dynamic>>(
      mutation,
      key: 'assignOrder',
      variables: {
        ...request.toJson(),
        if (request.sessionId == null)
          'sessionId': await gqlService.sessionId,
      },
    );

    return OrderDto.fromJson(data);
  }

  @override
  Future<List<OrderDto>> createBulkOrders(List<OrderCreateInput> orders) async {
    const mutation =
        '''
      mutation CreateBulkOrders(\$orders: [OrderCreateInput!]!, \$sessionId: String) {
        createBulkOrders(orders: \$orders, sessionId: \$sessionId) {
          ${GqlFragments.orderFields}
        }
      }
    ''';

    final data = await mutate<List<dynamic>>(
      mutation,
      key: 'createBulkOrders',
      variables: {
        'orders': orders.map((o) => o.toJson()).toList(),
        'sessionId': await gqlService.sessionId,
      },
    );

    return data
        .map((json) => OrderDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<OrderCreateInput>> parseTextToOrders(String text) async {
    const mutation = r'''
      mutation ParseOrders($text: String!) {
        parseOrders(text: $text) {
          orders {
            pickupAddress
            dropOffAddress
            pickupPhone
            dropOffPhone
            price
            description
          }
        }
      }
    ''';

    final result = await mutate<Map<String, dynamic>>(
      mutation,
      key: 'parseOrders',
      variables: {'text': text},
    );

    final orders = result['orders'] as List<dynamic>;
    return orders
        .map((o) => OrderCreateInput.fromJson(o as Map<String, dynamic>))
        .toList();
  }
}
