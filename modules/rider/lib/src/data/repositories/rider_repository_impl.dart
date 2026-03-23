import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/interfaces/store/store.dart';
import 'package:rider/src/data/datasources/rider_remote_datasource.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

class RiderRepositoryImpl implements RiderRepository {
  RiderRepositoryImpl({
    required RiderRemoteDataSource remoteDataSource,
    required OrderDao orderDao,
    required RiderDao riderDao,
    required StreamableObjectStore<RiderMetricsDto> metricsStore,
  }) : _remoteDataSource = remoteDataSource,
       _orderDao = orderDao,
       _riderDao = riderDao,
       _metricsStore = metricsStore;

  final RiderRemoteDataSource _remoteDataSource;
  final OrderDao _orderDao;
  final RiderDao _riderDao;
  final StreamableObjectStore<RiderMetricsDto> _metricsStore;

  // READ operations - stream from local DB
  @override
  Stream<Rider?> watchRiderProfile(String riderId) {
    return _riderDao.watchRider(riderId);
  }

  @override
  Stream<Order?> watchOrder(String orderId) {
    return _orderDao.watchOrder(orderId);
  }

  @override
  Stream<List<Order>> watchRiderOrders({
    List<OrderStatus>? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
    bool isPrioritySort = false,
  }) {
    final isAll = status == null || status.isEmpty;

    return _orderDao.watchOrders(
      statuses: status,
      searchQuery: searchQuery,
      includeUnassigned: isAll,
      limit: limit,
      offset: offset,
      isPrioritySort: isPrioritySort,
    );
  }

  @override
  Stream<RiderMetricsDto?> watchRiderMetrics() async* {
    yield await _metricsStore.get();
    yield* _metricsStore.watch();
  }

  // WRITE operations - go to server
  @override
  Future<Result<AppError, Rider>> updateRiderLocation(
    String riderId,
    double lat,
    double lng, {
    int? batteryLevel,
  }) async {
    return Result.tryCatch(() async {
      final dto = await _remoteDataSource.updateLocation(
        riderId,
        lat,
        lng,
        batteryLevel,
      );

      // Update local DB
      await _riderDao.upsertRider(dto.toDriftCompanion());

      return dto.toEntity();
    });
  }

  @override
  Future<Result<AppError, Rider?>> getRider(String riderId) async {
    return Result.tryCatch(() async {
      return _riderDao.getRider(riderId);
    });
  }

  @override
  Future<Result<AppError, Rider>> fetchProfile() async {
    return Result.tryCatch(() async {
      final dto = await _remoteDataSource.fetchProfile();
      await _riderDao.upsertRider(dto.toDriftCompanion());
      return dto.toEntity();
    });
  }

  @override
  Future<Result<AppError, Order>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    return Result.tryCatch(() async {
      final dto = await _remoteDataSource.updateOrderStatus(
        orderId,
        status.value,
      );

      // Update local DB immediately to reflect changes in UI
      // (since backend filters out current session in subscriptions)
      await _orderDao.upsertOrder(dto.toDriftCompanion());

      return dto.toEntity();
    });
  }

  @override
  Future<Result<AppError, Rider>> sendHeartbeat({
    required double lat,
    required double lng,
    int? batteryLevel,
  }) async {
    return Result.tryCatch(() async {
      final dto = await _remoteDataSource.sendHeartbeat(
        lat: lat,
        lng: lng,
        batteryLevel: batteryLevel,
      );

      // Update local DB with latest rider info (including status)
      await _riderDao.upsertRider(dto.toDriftCompanion());

      return dto.toEntity();
    });
  }
}
