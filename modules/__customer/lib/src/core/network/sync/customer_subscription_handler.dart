import 'package:shared/shared.dart';

class CustomerSubscriptionHandler extends BaseSubscriptionHandler {
  CustomerSubscriptionHandler({
    required super.deliveryDao,
    required super.riderDao,
    super.logger,
  });

  @override
  Future<void> handleDeliveryUpdate(
    String eventType,
    DeliveryDto? deliveryDto, {
    RiderDto? riderDto,
  }) async {
    await super.handleDeliveryUpdate(eventType, deliveryDto, riderDto: riderDto);
  }
}
