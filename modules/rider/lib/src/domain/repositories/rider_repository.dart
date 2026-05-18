import 'dart:io';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:rider/src/features/deliveries/data/dtos/rider_metrics_dto.dart';
import 'package:shared/shared.dart';

abstract class RiderRepository {
  // Read operations - stream from local DB
  Stream<Rider?> watchRiderProfile(String riderId);

  Stream<Delivery?> watchDelivery(String deliveryId);

  Stream<List<Delivery>> watchRiderDeliveries({
    List<DeliveryStatus>? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
    bool isPrioritySort = false,
  });

  Stream<RiderMetricsDto?> watchRiderMetrics();

  // Write operations - go to server
  Future<Result<AppError, Delivery>> updateDeliveryStatus(
    String deliveryId,
    DeliveryStatus status, {
    String? pin,
    String? proofImageUrl,
  });

  Future<Result<AppError, String>> uploadProofOfDelivery(
    String deliveryId,
    File file,
  );

  Future<Result<AppError, Rider>> fetchProfile();

  Future<Result<AppError, Rider>> sendHeartbeat({
    double? lat,
    double? lng,
    int? batteryLevel,
  });
}
