import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

abstract class RiderRepository {
  // Read operations - stream from local DB
  Stream<Rider?> watchRiderProfile(String riderId);

  Stream<Order?> watchOrder(String orderId);

  Stream<List<Order>> watchRiderOrders({
    List<OrderStatus>? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
    bool isPrioritySort = false,
  });

  Stream<RiderMetricsDto?> watchRiderMetrics();

  // Write operations - go to server
  Future<Result<AppError, Rider>> updateRiderLocation(
    String riderId,
    double lat,
    double lng, {
    int? batteryLevel,
  });

  Future<Result<AppError, Order>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  );

  Future<Result<AppError, Rider?>> getRider(String riderId);
  Future<Result<AppError, Rider>> fetchProfile();

  Future<Result<AppError, Rider>> sendHeartbeat({
    required double lat,
    required double lng,
    int? batteryLevel,
  });
}
