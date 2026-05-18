import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:dispatcher/src/features/deliveries/data/dtos/delivery_create_input.dart';
import 'package:shared/shared.dart';

abstract class DeliveryRepository {
  // Read operations - return streams from local DB
  Stream<List<Delivery>> watchDeliveries({
    List<DeliveryStatus>? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  });

  Future<Result<AppError, List<Delivery>>> getDeliveries({
    List<DeliveryStatus>? status,
    String? searchQuery,
    int limit = 20,
    DateTime? beforeDate,
    String? beforeId,
  });


  Stream<Delivery?> watchDelivery(String id);

  Stream<int> watchDeliveryCount({List<DeliveryStatus>? status});

  // Write operations - return futures (go to server)
  Future<Result<AppError, List<Delivery>>> createBulkDeliveries(
    List<DeliveryCreateInput> deliveries,
  );

  Future<Result<AppError, void>> updateDeliveryStatus(
    String deliveryId,
    DeliveryStatus status,
  );

  Future<Result<AppError, void>> assignRider(String deliveryId, Rider rider);

  Future<Result<AppError, void>> unassignRider(String deliveryId);

  Future<Result<AppError, void>> cancelDelivery(String deliveryId);

  Future<Result<AppError, void>> rejectDelivery(String deliveryId);

  // Utility operations
  Future<Result<AppError, List<DeliveryCreateInput>>> parseTextToDeliveries(
    String text,
  );
}
