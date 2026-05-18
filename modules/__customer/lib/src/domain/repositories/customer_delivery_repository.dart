import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:customer/src/data/dtos/customer_delivery_input.dart';
import 'package:shared/shared.dart';

abstract class CustomerDeliveryRepository {
  // Reactive reads (from local DB)
  Stream<List<Delivery>> watchDeliveries({int limit = 20, int offset = 0});
  Stream<Delivery?> watchDelivery(String id);

  // Commands (writes synchronously to server, then UI updates via streams)
  Future<Result<AppError, Delivery>> createDelivery(CustomerDeliveryInput input);
  
  // No direct refresh methods needed, handled by SessionManager
}
