import 'package:bootstrap/interfaces/store/store.dart';
import 'package:shared/shared.dart';

class RiderSubscriptionHandler extends BaseSubscriptionHandler {
  RiderSubscriptionHandler({
    required super.orderDao,
    required super.riderDao,
    required ObjectStore<RiderMetricsDto> metricsStore,
    super.logger,
  }) : _metricsStore = metricsStore;

  final ObjectStore<RiderMetricsDto> _metricsStore;

  @override
  Future<void> handleOrderUpdate(
    OrderDto? orderDto,
    String eventType, {
    RiderDto? riderDto,
    RiderMetricsDto? riderMetrics,
  }) async {
    await super.handleOrderUpdate(orderDto, eventType, riderDto: riderDto);

    if (riderMetrics != null) {
      await _metricsStore.set(riderMetrics);
    }
  }
}
