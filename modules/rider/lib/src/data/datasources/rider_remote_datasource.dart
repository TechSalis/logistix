import 'package:bootstrap/definitions/app_error.dart';
import 'package:shared/shared.dart';

abstract class RiderRemoteDataSource {
  Future<RiderDto> getMeRider();

  Future<RiderDto> updateLocation(
    String riderId,
    double lat,
    double lng,
    int? batteryLevel,
  );

  Future<OrderDto> getOrder(String orderId);
  
  Future<List<OrderDto>> getOrders({
    List<String>? status,
    int? limit,
    int? offset,
    String? sortOrder,
  });

  Future<void> updateOrderStatus(String orderId, String status);

  Future<RiderMetricsDto> getRiderMetrics();
}

class RiderRemoteDataSourceImpl implements RiderRemoteDataSource {
  RiderRemoteDataSourceImpl(this._graphQLService);
  final GraphQLService _graphQLService;

  @override
  Future<RiderDto> getMeRider() async {
    const query = '''
      query GetMeRider {
        meRider {
          id
          email
          phoneNumber
          fullName
          companyId
          status
          lastLat
          lastLng
          batteryLevel
          isAccepted
          isIndependent
          permitUrl
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await _graphQLService.query(query);
    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['meRider'] as Map<String, dynamic>?;
    if (data == null) {
      throw const AppError(message: 'Rider profile not found');
    }

    return RiderDto.fromJson(data);
  }

  @override
  Future<RiderDto> updateLocation(
    String riderId,
    double lat,
    double lng,
    int? batteryLevel,
  ) async {
    const mutation = r'''
      mutation UpdateRiderLocation($riderId: ID!, $lat: Float!, $lng: Float!, $batteryLevel: Int) {
        updateRiderLocation(riderId: $riderId, lat: $lat, lng: $lng, batteryLevel: $batteryLevel) {
          id
          fullName
          companyId
          status
          lastLat
          lastLng
          batteryLevel
          isAccepted
          isIndependent
          permitUrl
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await _graphQLService.mutate(
      mutation,
      variables: {
        'riderId': riderId,
        'lat': lat,
        'lng': lng,
        'batteryLevel': batteryLevel,
      },
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['updateRiderLocation'] as Map<String, dynamic>?;
    if (data == null) {
      throw const AppError(message: 'Failed to update rider location');
    }

    return RiderDto.fromJson(data);
  }

  @override
  Future<List<OrderDto>> getOrders({
    List<String>? status,
    int? limit,
    int? offset,
    String? sortOrder,
  }) async {
    const query = r'''
      query GetRiderOrders($status: [String!], $limit: Int, $offset: Int, $sortOrder: String) {
        myOrders(status: $status, limit: $limit, offset: $offset, sortOrder: $sortOrder) {
          id
          companyId
          riderId
          pickupAddress
          dropOffAddress
          items
          codAmount
          sequenceNumber
          trackingNumber
          status
          deliveredAt
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await _graphQLService.query(
      query,
      variables: {
        if (status != null) 'status': status,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
        if (sortOrder != null) 'sortOrder': sortOrder,
      },
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['myOrders'] as List<dynamic>?;
    return data
            ?.map((e) => OrderDto.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<OrderDto> getOrder(String orderId) async {
    const query = r'''
      query GetOrder($id: ID!) {
        order(id: $id) {
          id
          companyId
          riderId
          pickupAddress
          dropOffAddress
          items
          codAmount
          sequenceNumber
          trackingNumber
          status
          deliveredAt
          createdAt
          updatedAt
        }
      }
    ''';

    final result = await _graphQLService.query(
      query,
      variables: {'id': orderId},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['order'] as Map<String, dynamic>?;
    if (data == null) {
      throw const AppError(message: 'Order not found');
    }

    return OrderDto.fromJson(data);
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    const mutation = r'''
      mutation UpdateOrderStatus($orderId: ID!, $status: String!) {
        updateOrderStatus(orderId: $orderId, status: $status) {
          id
          status
        }
      }
    ''';

    final result = await _graphQLService.mutate(
      mutation,
      variables: {'orderId': orderId, 'status': status},
    );

    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }
  }

  @override
  Future<RiderMetricsDto> getRiderMetrics() async {
    const query = '''
      query GetRiderMetrics {
        deliveryMetrics {
          totalOrders
          pendingOrders
          inProgressOrders
          deliveredOrders
          codExpectedToday
          onlineRiders
          avgDeliveryTime
        }
      }
    ''';

    final result = await _graphQLService.query(query);
    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }

    final data = result.data?['deliveryMetrics'] as Map<String, dynamic>?;
    if (data == null) {
      throw const AppError(message: 'Rider metrics not found');
    }

    return RiderMetricsDto.fromJson(data);
  }
}
