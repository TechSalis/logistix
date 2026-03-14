import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:rider/src/data/datasources/rider_remote_datasource.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

class RiderRepositoryImpl implements RiderRepository {
  RiderRepositoryImpl(this._dataSource);
  final RiderRemoteDataSource _dataSource;

  @override
  Future<Result<AppError, Rider>> getRiderProfile() async {
    return await Result.tryCatch<AppError, Rider>(() async {
      final dto = await _dataSource.getMeRider();
      return dto.toEntity();
    });
  }

  @override
  Future<Result<AppError, Rider>> updateRiderLocation(
    String riderId,
    double lat,
    double lng, {
    int? batteryLevel,
  }) async {
    return await Result.tryCatch<AppError, Rider>(() async {
      final dto = await _dataSource.updateLocation(
        riderId,
        lat,
        lng,
        batteryLevel,
      );
      return dto.toEntity();
    });
  }

  @override
  Future<Result<AppError, Order>> getOrder(String orderId) async {
    return await Result.tryCatch<AppError, Order>(() async {
      final dto = await _dataSource.getOrder(orderId);
      return dto.toEntity();
    });
  }

  @override
  Future<Result<AppError, List<Order>>> getRiderOrders({
    List<OrderStatus>? status,
    int? limit,
    int? offset,
    String? sortOrder,
  }) async {
    return await Result.tryCatch<AppError, List<Order>>(() async {
      final dtos = await _dataSource.getOrders(
        status: status?.map((e) => e.value).toList(),
        limit: limit,
        offset: offset,
        sortOrder: sortOrder,
      );
      return dtos.map((dto) => dto.toEntity()).toList();
    });
  }

  @override
  Future<Result<AppError, void>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    return await Result.tryCatch<AppError, void>(() async {
      await _dataSource.updateOrderStatus(orderId, status.value);
    });
  }

  @override
  Future<Result<AppError, RiderMetrics>> getRiderMetrics() async {
    return await Result.tryCatch<AppError, RiderMetrics>(() async {
      final dto = await _dataSource.getRiderMetrics();
      return dto.toEntity();
    });
  }
}
