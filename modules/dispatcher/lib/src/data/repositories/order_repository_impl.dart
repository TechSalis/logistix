import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/data/datasources/order_remote_datasource.dart';
import 'package:dispatcher/src/data/dtos/order_create_input.dart';
import 'package:dispatcher/src/domain/repositories/order_repository.dart';
import 'package:dispatcher/src/domain/utils/order_parser.dart';
import 'package:shared/shared.dart';

class OrderRepositoryImpl implements OrderRepository {
  const OrderRepositoryImpl({
    required OrderRemoteDataSource remoteDataSource,
    required OrderDao orderDao,
    required RiderDao riderDao,
    required PlacesService placesService,
  }) : _remoteDataSource = remoteDataSource,
       _orderDao = orderDao,
       _riderDao = riderDao,
       _placesService = placesService;

  final OrderRemoteDataSource _remoteDataSource;
  final OrderDao _orderDao;
  final RiderDao _riderDao;
  final PlacesService _placesService;

  // READ operations - stream from local Drift DB
  @override
  Stream<List<Order>> watchOrders({
    List<OrderStatus>? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) {
    return _orderDao.watchOrders(
      statuses: status,
      searchQuery: searchQuery,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Stream<Order?> watchOrder(String id) => _orderDao.watchOrder(id);

  @override
  Stream<int> watchOrderCount({List<OrderStatus>? status}) {
    return _orderDao.watchOrderCount(statuses: status);
  }

  // WRITE operations - go to server, DB updated via subscription
  @override
  Future<Result<AppError, List<Order>>> createBulkOrders(
    List<OrderCreateInput> orders,
  ) async {
    return Result.tryCatch(() async {
      final dtos = await _remoteDataSource.createBulkOrders(orders);

      // Write to local DB immediately in batch (subscriptions may be delayed)
      await _orderDao.upsertOrders(
        dtos.map((dto) => dto.toDriftCompanion()).toList(),
      );

      return dtos.map((dto) => dto.toEntity()).toList();
    });
  }

  @override
  Future<Result<AppError, void>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    final currentOrder = await _orderDao.getOrder(orderId);

    // Optimistically update local DB
    if (currentOrder != null) {
      await _orderDao.upsertOrder(
        currentOrder.copyWith(status: status).toDriftCompanion(),
      );
    }

    final result = await Result.tryCatch<AppError, void>(() async {
      final dto = await _remoteDataSource.updateOrderStatus(
        orderId,
        status.value,
      );
      await _orderDao.upsertOrder(dto.toDriftCompanion());
    });

    if (result.isError && currentOrder != null) {
      await _orderDao.upsertOrder(currentOrder.toDriftCompanion());
    }

    return result;
  }

  @override
  Future<Result<AppError, void>> assignRider(
    String orderId,
    Rider rider,
  ) async {
    final currentOrder = await _orderDao.getOrder(orderId);

    // Optimistically update local DB
    if (currentOrder != null) {
      await Future.wait<void>([
        _riderDao.upsertRider(rider.toDriftCompanion()),
        _orderDao.upsertOrder(
          currentOrder
              .copyWith(
                riderId: rider.id,
                rider: rider,
                status: OrderStatus.assigned,
              )
              .toDriftCompanion(),
        ),
      ]);
    }

    final result = await Result.tryCatch<AppError, void>(() async {
      final dto = await _remoteDataSource.assignOrder(orderId, rider.id);
      await _orderDao.upsertOrder(dto.toDriftCompanion());
    });

    if (result.isError && currentOrder != null) {
      await _orderDao.upsertOrder(currentOrder.toDriftCompanion());
    }

    return result;
  }

  @override
  Future<Result<AppError, void>> unassignRider(String orderId) async {
    final currentOrder = await _orderDao.getOrder(orderId);

    // Optimistically update local DB
    if (currentOrder != null) {
      await _orderDao.upsertOrder(
        currentOrder
            .copyWith(
              riderId: null,
              rider: null,
              status: OrderStatus.unassigned,
            )
            .toDriftCompanion(),
      );
    }

    final result = await Result.tryCatch<AppError, void>(() async {
      final dto = await _remoteDataSource.updateOrderStatus(
        orderId,
        OrderStatus.unassigned.value,
      );

      await _orderDao.upsertOrder(dto.toDriftCompanion());
    });

    if (result.isError && currentOrder != null) {
      await _orderDao.upsertOrder(currentOrder.toDriftCompanion());
    }

    return result;
  }

  @override
  Future<Result<AppError, void>> cancelOrder(String orderId) {
    return updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  @override
  Future<Result<AppError, List<OrderCreateInput>>> parseTextToOrders(
    String text,
  ) async {
    return Result.tryCatch(() async {
      // 1. Local heuristic parser with confidence scoring
      final localResult = await OrderParser.parse(text);

      List<OrderCreateInput> results;

      if (localResult.needsRemoteFallback) {
        // 2. Fallback: remote endpoint (future LLM integration point).
        //    Currently uses the backend NLP engine as a secondary attempt.
        try {
          results = await _remoteDataSource.parseTextToOrders(text);
        } catch (_) {
          // Remote also failed — return what local found (even if low confidence)
          // to avoid a completely empty result.
          results = localResult.orders.map((p) => p.order).toList();
        }
      } else {
        results = localResult.orders.map((p) => p.order).toList();
      }

      if (results.isEmpty) return [];

      // 3. Parallel Google Places resolution for extracted addresses
      // We perform all resolutions in parallel using high-performance fuzzy word matching
      final withPlaces = await Future.wait(
        results.map((order) => _resolveOrderLocations(order)),
      );

      return withPlaces;
    });
  }

  /// Private helper to coordinate dual-address resolution using fuzzy Places matching
  Future<OrderCreateInput> _resolveOrderLocations(OrderCreateInput order) async {
    final hasDropOff = order.dropOffAddress.isNotEmpty;
    final hasPickup = order.pickupAddress?.isNotEmpty ?? false;

    // Fire off both place lookups concurrently
    final lookups = await Future.wait([
      if (hasDropOff) _placesService.findBestMatch(order.dropOffAddress),
      if (hasPickup) _placesService.findBestMatch(order.pickupAddress!),
    ]);

    final dropOffMatch = hasDropOff ? lookups[0] : null;
    final pickupMatch = hasPickup ? (hasDropOff ? lookups[1] : lookups[0]) : null;

    return order.copyWith(
      dropOffAddress: dropOffMatch?.formattedAddress ?? order.dropOffAddress,
      dropOffPlaceId: dropOffMatch?.placeId,
      pickupAddress: pickupMatch?.formattedAddress ?? order.pickupAddress,
      pickupPlaceId: pickupMatch?.placeId,
    );
  }
}
