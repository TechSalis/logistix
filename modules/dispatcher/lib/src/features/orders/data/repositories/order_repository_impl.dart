import 'dart:async';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:dispatcher/src/features/orders/data/dtos/assign_order_request.dart';
import 'package:dispatcher/src/features/orders/data/dtos/order_create_input.dart';
import 'package:dispatcher/src/features/orders/data/dtos/update_order_status_request.dart';
import 'package:dispatcher/src/features/orders/domain/repositories/order_repository.dart';
import 'package:dispatcher/src/features/orders/domain/utils/order_parser.dart';
import 'package:shared/shared.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({
    required OrderRemoteDataSource remoteDataSource,
    required OrderDao orderDao,
    required RiderDao riderDao,
    required PlacesService placesService,
    required UserStore userStore,
  }) : _remoteDataSource = remoteDataSource,
       _orderDao = orderDao,
       _riderDao = riderDao,
       _placesService = placesService,
       _userStore = userStore;

  final OrderRemoteDataSource _remoteDataSource;
  final OrderDao _orderDao;
  final RiderDao _riderDao;
  final PlacesService _placesService;
  final UserStore _userStore;

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
  Future<Result<AppError, List<Order>>> getOrders({
    List<OrderStatus>? status,
    String? searchQuery,
    int limit = 20,
    DateTime? beforeDate,
    String? beforeId,
  }) async {
    return Result.tryCatch(() {
      return _orderDao.getOrders(
        statuses: status,
        searchQuery: searchQuery,
        limit: limit,
        beforeDate: beforeDate,
        beforeId: beforeId,
      );
    });
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
      final companionList = dtos.map((dto) => dto.toDriftCompanion()).toList();
      await _orderDao.upsertOrders(companionList);

      final entities = dtos.map((dto) => dto.toEntity()).toList();

      return entities;
    });
  }

  @override
  Future<Result<AppError, void>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) {
    return _optimisticUpdate(
      orderId: orderId,
      applyLocal: (order) => order.copyWith(status: status),
      remoteCall: () => _remoteDataSource.updateOrderStatus(
        UpdateOrderStatusRequest(orderId: orderId, status: status.name),
      ),
    );
  }

  @override
  Future<Result<AppError, void>> assignRider(
    String orderId,
    Rider rider,
  ) async {
    return _optimisticUpdate(
      orderId: orderId,
      applyLocal: (order) => order.copyWith(
        riderId: rider.id,
        rider: rider,
        status: OrderStatus.ASSIGNED,
      ),
      remoteCall: () async {
        // Riders are syncable too, so we upsert here
        await _riderDao.upsertRider(rider.toDriftCompanion());
        return _remoteDataSource.assignOrder(
          AssignOrderRequest(orderId: orderId, riderId: rider.id),
        );
      },
    );
  }

  @override
  Future<Result<AppError, void>> unassignRider(String orderId) {
    return _optimisticUpdate(
      orderId: orderId,
      applyLocal: (order) => order.copyWith(status: OrderStatus.UNASSIGNED),
      remoteCall: () => _remoteDataSource.updateOrderStatus(
        UpdateOrderStatusRequest(
          orderId: orderId,
          status: OrderStatus.UNASSIGNED.name,
        ),
      ),
    );
  }

  @override
  Future<Result<AppError, void>> cancelOrder(String orderId) {
    return updateOrderStatus(orderId, OrderStatus.CANCELLED);
  }

  @override
  Future<Result<AppError, void>> rejectOrder(String orderId) {
    return _optimisticUpdate(
      orderId: orderId,
      applyLocal: (order) => order.copyWith(status: OrderStatus.UNASSIGNED),
      remoteCall: () => _remoteDataSource.rejectOrder(orderId),
    );
  }

  /// High-performance helper to coordinate optimistic local updates with remote sync and automatic rollback.
  Future<Result<AppError, void>> _optimisticUpdate({
    required String orderId,
    required Order Function(Order) applyLocal,
    required Future<OrderDto> Function() remoteCall,
  }) async {
    final currentOrder = await _orderDao.getOrder(orderId);

    if (currentOrder != null) {
      final updated = applyLocal(currentOrder);
      await _orderDao.upsertOrder(updated.toDriftCompanion());
    }

    final result = await Result.tryCatch<AppError, void>(() async {
      final dto = await remoteCall();
      await _orderDao.upsertOrder(dto.toDriftCompanion());
    });

    if (result.isError && currentOrder != null) {
      await _orderDao.upsertOrder(currentOrder.toDriftCompanion());
    }

    return result;
  }

  @override
  Future<Result<AppError, List<OrderCreateInput>>> parseTextToOrders(
    String text,
  ) async {
    return Result.tryCatch(() async {
      // 1. Local heuristic parser with confidence scoring
      final localResult = await OrderParser.parse(text);

      List<OrderCreateInput>? results;

      if (!localResult.needsRemoteFallback && localResult.orders.isNotEmpty) {
        results = localResult.orders.map((p) => p.order).toList();
      }

      // 2. Telemetry Fallback - Capture text and parse on backend if local parser struggles
      // Gated to STARTER and PROFESSIONAL tiers
      final tier = _userStore.user?.companyProfile?.config?.tier ?? BillingTier.free;
      final hasAiAccess = tier == BillingTier.starter || tier == BillingTier.professional;

      if (hasAiAccess && (results == null || localResult.needsRemoteFallback)) {
        try {
          final remoteResults = await _remoteDataSource.parseTextToOrders(text);
          if (remoteResults.isNotEmpty) {
            results = remoteResults;
          }
        } on Object catch (_) {
          // Fallback to empty if remote also fails, but keep local results if they existed
        }
      }

      if (results == null) return [];

      // 3. Parallel Google Places resolution for extracted addresses
      // We perform all resolutions in parallel using high-performance fuzzy word matching
      final withPlaces = await Future.wait(results.map(_resolveOrderLocations));

      return withPlaces;
    });
  }

  /// Private helper to coordinate dual-address resolution using fuzzy Places matching
  Future<OrderCreateInput> _resolveOrderLocations(
    OrderCreateInput order,
  ) async {
    final hasDropOff = order.dropOffAddress.isNotEmpty;
    final hasPickup = order.pickupAddress?.isNotEmpty ?? false;

    // Fire off both place lookups concurrently
    final lookups = await Future.wait([
      if (hasDropOff) _placesService.findBestMatch(order.dropOffAddress),
      if (hasPickup) _placesService.findBestMatch(order.pickupAddress!),
    ]);

    final dropOffMatch = hasDropOff ? lookups[0] : null;
    final pickupMatch = hasPickup
        ? (hasDropOff ? lookups[1] : lookups[0])
        : null;

    return order.copyWith(
      dropOffAddress: dropOffMatch?.formattedAddress ?? order.dropOffAddress,
      dropOffPlaceId: dropOffMatch?.placeId,
      pickupAddress: pickupMatch?.formattedAddress ?? order.pickupAddress,
      pickupPlaceId: pickupMatch?.placeId,
    );
  }
}
