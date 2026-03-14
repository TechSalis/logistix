import 'package:bootstrap/definitions/app_error.dart';
import 'package:shared/shared.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderDto>> getOrders({
    List<String>? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  });

  Future<OrderDto> createOrder(OrderCreateInput input);

  Future<List<OrderDto>> createBulkOrders(List<OrderCreateInput> orders);

  Future<OrderDto> getOrder(String id);
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> assignOrder(String orderId, String riderId);

  Future<List<OrderCreateInput>> parseTextToOrders(String text);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  OrderRemoteDataSourceImpl(this._gqlService);
  final GraphQLService _gqlService;

  static const _orderFields = '''
    id
    companyId
    pickupAddress
    dropOffAddress
    trackingNumber
    status
    items
    codAmount
    customerName
    customerPhone
    description
    sequenceNumber
    deliveredAt
    createdAt
    updatedAt
    rider {
      id
      companyId
      email
      fullName
      phoneNumber
      status
      lastLat
      lastLng
    }
  ''';

  @override
  Future<OrderDto> getOrder(String id) async {
    const query =
        '''
      query GetOrder(\$id: ID!) {
        order(id: \$id) {
          $_orderFields
        }
      }
    ''';

    final result = await _gqlService.query(query, variables: {'id': id});
    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['order'];
    if (data == null) throw const AppError(message: 'Order not found');

    return OrderDto.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    const mutation = r'''
      mutation UpdateOrderStatus($orderId: ID!, $status: String!) {
        updateOrderStatus(orderId: $orderId, status: $status) {
          id
        }
      }
    ''';

    final result = await _gqlService.mutate(
      mutation,
      variables: {'orderId': orderId, 'status': status},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }
  }

  @override
  Future<void> assignOrder(String orderId, String riderId) async {
    const mutation = r'''
      mutation AssignOrder($orderId: ID!, $riderId: ID!) {
        assignOrder(orderId: $orderId, riderId: $riderId) {
          id
        }
      }
    ''';

    final result = await _gqlService.mutate(
      mutation,
      variables: {'orderId': orderId, 'riderId': riderId},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }
  }

  @override
  Future<List<OrderDto>> getOrders({
    List<String>? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    const query = r'''
      query GetOrders($status: [String!], $search: String, $limit: Int, $offset: Int) {
        orders(status: $status, search: $search, limit: $limit, offset: $offset) {
          id
          companyId
          pickupAddress
          dropOffAddress
          trackingNumber
          status
          items
          codAmount
          sequenceNumber
          deliveredAt
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await _gqlService.query(
      query,
      variables: {
        'status': status,
        'search': searchQuery,
        'limit': limit,
        'offset': offset,
      },
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['orders'] as List?;
    if (data == null) return [];
    return data
        .map((json) => OrderDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OrderDto> createOrder(OrderCreateInput input) async {
    const mutation = r'''
      mutation CreateOrder($input: OrderCreateInput!) {
        createOrder(input: $input) {
          id
          companyId
          pickupAddress
          dropOffAddress
          trackingNumber
          createdAt
        }
      }
    ''';

    final result = await _gqlService.mutate(
      mutation,
      variables: {'input': input.toJson()},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['createOrder'] as Map<String, dynamic>?;
    if (data == null) {
      throw const AppError(message: 'Failed to create order');
    }

    return OrderDto.fromJson(data);
  }

  @override
  Future<List<OrderDto>> createBulkOrders(List<OrderCreateInput> orders) async {
    const mutation = r'''
      mutation CreateBulkOrders($orders: [OrderCreateInput!]!) {
        createBulkOrders(orders: $orders) {
          id
          companyId
          pickupAddress
          dropOffAddress
          trackingNumber
          createdAt
        }
      }
    ''';

    final result = await _gqlService.mutate(
      mutation,
      variables: {'orders': orders.map((o) => o.toJson()).toList()},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['createBulkOrders'] as List?;
    if (data == null) {
      throw const AppError(message: 'Failed to create bulk orders');
    }

    return data
        .map((json) => OrderDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<OrderCreateInput>> parseTextToOrders(String text) async {
    const mutation = r'''
      mutation ParseOrders($text: String!) {
        parseOrders(text: $text) {
          pickupAddress
          dropOffAddress
          items
          description
          codAmount
          customerPhone
        }
      }
    ''';

    final result = await _gqlService.mutate(
      mutation,
      variables: {'text': text},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['parseOrders'] as List?;
    if (data == null) {
      throw const AppError(message: 'Failed to parse orders');
    }

    return data
        .map((json) => OrderCreateInput.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
