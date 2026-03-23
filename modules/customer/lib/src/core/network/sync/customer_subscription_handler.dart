import 'package:shared/shared.dart';

class CustomerSubscriptionHandler extends BaseSubscriptionHandler {
  CustomerSubscriptionHandler({
    required super.orderDao,
    required super.riderDao,
    super.logger,
  });

  @override
  Future<void> handleOrderUpdate(
    OrderDto orderDto,
    String eventType, {
    RiderDto? riderDto,
  }) async {
    await super.handleOrderUpdate(orderDto, eventType, riderDto: riderDto);
  }
}
