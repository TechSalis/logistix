import 'dart:async';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/features/deliveries/data/datasources/delivery_remote_datasource.dart';
import 'package:dispatcher/src/features/deliveries/data/dtos/assign_delivery_request.dart';
import 'package:dispatcher/src/features/deliveries/data/dtos/delivery_create_input.dart';
import 'package:dispatcher/src/features/deliveries/data/dtos/update_delivery_status_request.dart';
import 'package:dispatcher/src/features/deliveries/domain/repositories/delivery_repository.dart';
import 'package:dispatcher/src/features/deliveries/domain/utils/delivery_parser.dart';
import 'package:shared/shared.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  DeliveryRepositoryImpl({
    required DeliveryRemoteDataSource remoteDataSource,
    required DeliveryDao deliveryDao,
    required RiderDao riderDao,
    required PlacesService placesService,
    required UserStore userStore,
  }) : _remoteDataSource = remoteDataSource,
       _deliveryDao = deliveryDao,
       _riderDao = riderDao,
       _placesService = placesService,
       _userStore = userStore;

  final DeliveryRemoteDataSource _remoteDataSource;
  final DeliveryDao _deliveryDao;
  final RiderDao _riderDao;
  final PlacesService _placesService;
  final UserStore _userStore;

  // READ operations - stream from local Drift DB
  @override
  Stream<List<Delivery>> watchDeliveries({
    List<DeliveryStatus>? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) {
    return _deliveryDao.watchDeliveries(
      statuses: status,
      searchQuery: searchQuery,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<Result<AppError, List<Delivery>>> getDeliveries({
    List<DeliveryStatus>? status,
    String? searchQuery,
    int limit = 20,
    DateTime? beforeDate,
    String? beforeId,
  }) async {
    return Result.tryCatch(() {
      return _deliveryDao.getDeliveries(
        statuses: status,
        searchQuery: searchQuery,
        limit: limit,
        beforeDate: beforeDate,
        beforeId: beforeId,
      );
    });
  }

  @override
  Stream<Delivery?> watchDelivery(String id) => _deliveryDao.watchDelivery(id);

  @override
  Stream<int> watchDeliveryCount({List<DeliveryStatus>? status}) {
    return _deliveryDao.watchDeliveryCount(statuses: status);
  }

  // WRITE operations - go to server, DB updated via subscription
  @override
  Future<Result<AppError, List<Delivery>>> createBulkDeliveries(
    List<DeliveryCreateInput> deliveries,
  ) async {
    return Result.tryCatch(() async {
      final dtos = await _remoteDataSource.createBulkDeliveries(deliveries);

      // Write to local DB immediately in batch (subscriptions may be delayed)
      final companionList = dtos.map((dto) => dto.toDriftCompanion()).toList();
      await _deliveryDao.upsertDeliveries(companionList);

      final entities = dtos.map((dto) => dto.toEntity()).toList();

      return entities;
    });
  }

  @override
  Future<Result<AppError, void>> updateDeliveryStatus(
    String deliveryId,
    DeliveryStatus status,
  ) {
    return _optimisticUpdate(
      deliveryId: deliveryId,
      applyLocal: (delivery) => delivery.copyWith(status: status),
      remoteCall: () => _remoteDataSource.updateDeliveryStatus(
        UpdateDeliveryStatusRequest(deliveryId: deliveryId, status: status.name),
      ),
    );
  }

  @override
  Future<Result<AppError, void>> assignRider(
    String deliveryId,
    Rider rider,
  ) async {
    return _optimisticUpdate(
      deliveryId: deliveryId,
      applyLocal: (delivery) => delivery.copyWith(
        riderId: rider.id,
        rider: rider,
        status: DeliveryStatus.ASSIGNED,
      ),
      remoteCall: () async {
        // Riders are syncable too, so we upsert here
        await _riderDao.upsertRider(rider.toDriftCompanion());
        return _remoteDataSource.assignDelivery(
          AssignDeliveryRequest(deliveryId: deliveryId, riderId: rider.id),
        );
      },
    );
  }

  @override
  Future<Result<AppError, void>> unassignRider(String deliveryId) {
    return _optimisticUpdate(
      deliveryId: deliveryId,
      applyLocal: (delivery) => delivery.copyWith(status: DeliveryStatus.PENDING),
      remoteCall: () => _remoteDataSource.updateDeliveryStatus(
        UpdateDeliveryStatusRequest(
          deliveryId: deliveryId,
          status: DeliveryStatus.PENDING.name,
        ),
      ),
    );
  }

  @override
  Future<Result<AppError, void>> cancelDelivery(String deliveryId) {
    return updateDeliveryStatus(deliveryId, DeliveryStatus.CANCELLED);
  }

  @override
  Future<Result<AppError, void>> rejectDelivery(String deliveryId) {
    return _optimisticUpdate(
      deliveryId: deliveryId,
      applyLocal: (delivery) => delivery.copyWith(status: DeliveryStatus.PENDING),
      remoteCall: () => _remoteDataSource.rejectDelivery(deliveryId),
    );
  }

  /// High-performance helper to coordinate optimistic local updates with remote sync and automatic rollback.
  Future<Result<AppError, void>> _optimisticUpdate({
    required String deliveryId,
    required Delivery Function(Delivery) applyLocal,
    required Future<DeliveryDto> Function() remoteCall,
  }) async {
    final currentDelivery = await _deliveryDao.getDelivery(deliveryId);

    if (currentDelivery != null) {
      final updated = applyLocal(currentDelivery);
      await _deliveryDao.upsertDelivery(updated.toDriftCompanion());
    }

    final result = await Result.tryCatch<AppError, void>(() async {
      final dto = await remoteCall();
      await _deliveryDao.upsertDelivery(dto.toDriftCompanion());
    });

    if (result.isError && currentDelivery != null) {
      await _deliveryDao.upsertDelivery(currentDelivery.toDriftCompanion());
    }

    return result;
  }

  @override
  Future<Result<AppError, List<DeliveryCreateInput>>> parseTextToDeliveries(
    String text,
  ) async {
    return Result.tryCatch(() async {
      // 1. Local heuristic parser with confidence scoring
      final localResult = await DeliveryParser.parse(text);

      List<DeliveryCreateInput>? results;

      if (!localResult.needsRemoteFallback && localResult.deliveries.isNotEmpty) {
        results = localResult.deliveries.map((p) => p.delivery).toList();
      }

      // 2. Telemetry Fallback - Capture text and parse on backend if local parser struggles
      // Gated to STARTER and PROFESSIONAL tiers
      final tier = _userStore.user?.companyProfile?.config?.tier ?? SubscriptionTier.free;
      final hasAiAccess = tier == SubscriptionTier.starter || tier == SubscriptionTier.professional;

      if (hasAiAccess && (results == null || localResult.needsRemoteFallback)) {
        try {
          final remoteResults = await _remoteDataSource.parseTextToDeliveries(text);
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
      final withPlaces = await Future.wait(results.map(_resolveDeliveryLocations));

      return withPlaces;
    });
  }

  /// Private helper to coordinate dual-address resolution using fuzzy Places matching
  Future<DeliveryCreateInput> _resolveDeliveryLocations(
    DeliveryCreateInput delivery,
  ) async {
    final hasDropOff = delivery.dropOffAddress.isNotEmpty;
    final hasPickup = delivery.pickupAddress?.isNotEmpty ?? false;

    // Fire off both place lookups concurrently
    final lookups = await Future.wait([
      if (hasDropOff) _placesService.findBestMatch(delivery.dropOffAddress),
      if (hasPickup) _placesService.findBestMatch(delivery.pickupAddress!),
    ]);

    final dropOffMatch = hasDropOff ? lookups[0] : null;
    final pickupMatch = hasPickup
        ? (hasDropOff ? lookups[1] : lookups[0])
        : null;

    return delivery.copyWith(
      dropOffAddress: dropOffMatch?.formattedAddress ?? delivery.dropOffAddress,
      dropOffPlaceId: dropOffMatch?.placeId,
      pickupAddress: pickupMatch?.formattedAddress ?? delivery.pickupAddress,
      pickupPlaceId: pickupMatch?.placeId,
    );
  }
}
