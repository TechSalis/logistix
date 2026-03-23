import 'package:bootstrap/interfaces/store/store.dart';
import 'package:shared/shared.dart';

class DispatcherSubscriptionHandler extends BaseSubscriptionHandler {
  DispatcherSubscriptionHandler({
    required super.orderDao,
    required super.riderDao,
    required ObjectStore<DispatcherMetricsDto> metricsStore,
    super.logger,
  }) : _metricsStore = metricsStore;

  final ObjectStore<DispatcherMetricsDto> _metricsStore;

  @override
  Future<void> handleOrderUpdate(
    OrderDto orderDto,
    String eventType, {
    RiderDto? riderDto,
    DispatcherMetricsDto? dispatcherMetrics,
  }) async {
    await super.handleOrderUpdate(orderDto, eventType, riderDto: riderDto);

    if (dispatcherMetrics != null) {
      await _metricsStore.set(dispatcherMetrics);
    }
  }

  @override
  Future<void> handleRiderUpdate(
    RiderDto riderDto,
    String eventType, {
    DispatcherMetricsDto? dispatcherMetrics,
  }) async {
    await super.handleRiderUpdate(riderDto, eventType);

    if (dispatcherMetrics != null) {
      await _metricsStore.set(dispatcherMetrics);
    }
  }
}
