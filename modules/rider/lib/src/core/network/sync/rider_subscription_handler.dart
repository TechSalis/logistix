import 'package:bootstrap/interfaces/store/store.dart';
import 'package:rider/src/features/orders/data/dtos/rider_metrics_dto.dart';
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
    String eventType,
    OrderDto? orderDto, {
    RiderDto? riderDto,
    RiderMetricsDto? riderMetrics,
  }) async {
    await super.handleOrderUpdate(eventType, orderDto, riderDto: riderDto);

    if (riderMetrics != null) {
      await _metricsStore.set(riderMetrics);
    }
  }
}
