import 'dart:io';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:bootstrap/interfaces/store/store.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:rider/src/data/datasources/rider_remote_datasource.dart';
import 'package:rider/src/data/dtos/rider_heartbeat_request.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:rider/src/features/deliveries/data/dtos/rider_metrics_dto.dart';
import 'package:rider/src/features/deliveries/data/dtos/update_delivery_status_request.dart';
import 'package:shared/shared.dart';

class RiderRepositoryImpl implements RiderRepository {
  RiderRepositoryImpl({
    required RiderRemoteDataSource remoteDataSource,
    required DeliveryDao deliveryDao,
    required RiderDao riderDao,
    required StreamableObjectStore<RiderMetricsDto> metricsStore,
    required Dio dio,
  }) : _remoteDataSource = remoteDataSource,
       _deliveryDao = deliveryDao,
       _riderDao = riderDao,
       _metricsStore = metricsStore,
       _dio = dio;

  final RiderRemoteDataSource _remoteDataSource;
  final DeliveryDao _deliveryDao;
  final RiderDao _riderDao;
  final StreamableObjectStore<RiderMetricsDto> _metricsStore;
  final Dio _dio;

  // READ operations - stream from local DB
  @override
  Stream<Rider?> watchRiderProfile(String riderId) {
    return _riderDao.watchRider(riderId);
  }

  @override
  Stream<Delivery?> watchDelivery(String deliveryId) {
    return _deliveryDao.watchDelivery(deliveryId);
  }

  @override
  Stream<List<Delivery>> watchRiderDeliveries({
    List<DeliveryStatus>? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
    bool isPrioritySort = false,
  }) {
    final isAll = status == null || status.isEmpty;

    return _deliveryDao.watchDeliveries(
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
  Future<Result<AppError, Rider>> fetchProfile() async {
    return Result.tryCatch(() async {
      final dto = await _remoteDataSource.fetchProfile();
      await _riderDao.upsertRider(dto.toDriftCompanion());
      return dto.toEntity();
    });
  }

  @override
  Future<Result<AppError, Delivery>> updateDeliveryStatus(
    String deliveryId,
    DeliveryStatus status, {
    String? pin,
    String? proofImageUrl,
  }) async {
    final original = await _deliveryDao.getDelivery(deliveryId);

    // Optimistic local update
    if (original != null) {
      await _deliveryDao.upsertDelivery(
        original.toDriftCompanion().copyWith(status: Value(status.name)),
      );
    }

    return Result.tryCatch(() async {
      try {
        final request = UpdateDeliveryStatusRequest(
          deliveryId: deliveryId,
          status: status.name,
          pin: pin,
          proofImageUrl: proofImageUrl,
        );
        final dto = await _remoteDataSource.updateDeliveryStatus(request);

        // Final update with server response
        await _deliveryDao.upsertDelivery(dto.toDriftCompanion());

        return dto.toEntity();
      } catch (e) {
        // Rollback on failure to maintain data integrity
        if (original != null) {
          await _deliveryDao.upsertDelivery(original.toDriftCompanion());
        }
        rethrow;
      }
    });
  }

  @override
  Future<Result<AppError, String>> uploadProofOfDelivery(
    String deliveryId,
    File file,
  ) async {
    return Result.tryCatch(() async {
      // 1. Get presigned URL
      final presignedUrl =
          await _remoteDataSource.generatePresignedUploadUrl(deliveryId);

      // 2. Upload file via PUT
      final dio = _dio;
      final bytes = await file.readAsBytes();
      
      final response = await dio.put<dynamic>(
        presignedUrl,
        data: Stream.fromIterable([bytes]),
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: 'image/jpeg',
            HttpHeaders.contentLengthHeader: bytes.length,
          },
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to upload image to storage');
      }

      // The presigned URL (without query params) is usually the final URL, 
      // but the backend might return a different one or we just use the base.
      // For this system, we'll strip the query params to get the storage URL.
      return presignedUrl.split('?').first;
    });
  }

  @override
  Future<Result<AppError, Rider>> sendHeartbeat({
    double? lat,
    double? lng,
    int? batteryLevel,
  }) async {
    return Result.tryCatch(() async {
      final request = RiderHeartbeatRequest(
        lat: lat,
        lng: lng,
        batteryLevel: batteryLevel,
      );
      final dto = await _remoteDataSource.sendHeartbeat(request);

      // Update local DB with latest rider info (including status)
      await _riderDao.upsertRider(dto.toDriftCompanion());

      return dto.toEntity();
    });
  }
}
