import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

class DispatcherSubscriptionHandler extends BaseSubscriptionHandler {
  DispatcherSubscriptionHandler({
    required super.orderDao,
    required super.riderDao,
    required LogistixDatabase database,
    super.logger,
  }) : _database = database;

  final LogistixDatabase _database;

  @override
  @mustCallSuper
  Future<void> handleOrderUpdate(
    OrderDto? orderDto,
    String eventType, {
    RiderDto? riderDto,
    DispatcherMetricsDto? dispatcherMetrics,
  }) async {
    await super.handleOrderUpdate(orderDto, eventType, riderDto: riderDto);

    if (dispatcherMetrics != null) {
      final companyId = orderDto?.companyId ?? riderDto?.companyId;
      if (companyId != null) {
        await _database.upsertDispatcherMetrics(
          dispatcherMetrics.toDriftCompanion(companyId),
        );
      }
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
      await _database.upsertDispatcherMetrics(
        dispatcherMetrics.toDriftCompanion(riderDto.companyId),
      );
    }
  }
}
