import 'package:bootstrap/interfaces/store/store.dart';
import 'package:dispatcher/src/features/orders/data/dtos/dispatcher_metrics_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class DispatcherSubscriptionHandler extends BaseSubscriptionHandler {
  DispatcherSubscriptionHandler({
    required super.orderDao,
    required super.riderDao,
    required StreamableObjectStore<DispatcherMetricsDto> metricsStore,
    super.logger,
  }) : _metricsStore = metricsStore;

  final StreamableObjectStore<DispatcherMetricsDto> _metricsStore;

  @override
  @mustCallSuper
  Future<void> handleOrderUpdate(
    String eventType,
    OrderDto? orderDto, {
    RiderDto? riderDto,
    DispatcherMetricsDto? dispatcherMetrics,
  }) async {
    await super.handleOrderUpdate(eventType, orderDto, riderDto: riderDto);

    if (dispatcherMetrics != null) {
      final current = await _metricsStore.get() ?? const DispatcherMetricsDto();
      await _metricsStore.set(current.merge(dispatcherMetrics));
    }
  }

  @override
  @mustCallSuper
  Future<void> handleRiderUpdate(
    RiderDto riderDto,
    String eventType, {
    DispatcherMetricsDto? dispatcherMetrics,
  }) async {
    await super.handleRiderUpdate(riderDto, eventType);

    if (dispatcherMetrics != null) {
      final current = await _metricsStore.get() ?? const DispatcherMetricsDto();
      await _metricsStore.set(current.merge(dispatcherMetrics));
    }
  }
}
