import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:shared/shared.dart';

abstract class RiderRepository {
  Future<Result<AppError, Rider>> getRiderProfile();
  Future<Result<AppError, Rider>> updateRiderLocation(
    String riderId,
    double lat,
    double lng, {
    int? batteryLevel,
  });
  Future<Result<AppError, Order>> getOrder(String orderId);
  Future<Result<AppError, List<Order>>> getRiderOrders({
    List<OrderStatus>? status,
    int? limit,
    int? offset,
    String? sortOrder,
  });
  Future<Result<AppError, void>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  );
  Future<Result<AppError, RiderMetrics>> getRiderMetrics();
}
