import 'package:shared/shared.dart';

class CustomerSubscriptionHandler extends BaseSubscriptionHandler {
  CustomerSubscriptionHandler({
    required super.orderDao,
    required super.riderDao,
    super.logger,
  });

  @override
  Future<void> handleOrderUpdate(
    String eventType,
    OrderDto? orderDto, {
    RiderDto? riderDto,
  }) async {
    await super.handleOrderUpdate(eventType, orderDto, riderDto: riderDto);
  }
}
