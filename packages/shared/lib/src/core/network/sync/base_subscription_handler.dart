import 'package:bootstrap/interfaces/logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

enum EventType { created, updated, deleted }

extension EventTypeX on EventType {
  String get value => name.toUpperCase();

  static EventType fromString(String value) {
    return EventType.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => EventType.updated,
    );
  }
}

abstract class BaseSubscriptionHandler {
  BaseSubscriptionHandler({
    required this.orderDao,
    required this.riderDao,
    this.logger,
  });

  @protected
  final OrderDao orderDao;
  @protected
  final RiderDao riderDao;
  @protected
  final Logger? logger;

  @mustCallSuper
  Future<void> handleOrderUpdate(
    OrderDto? orderDto,
    String eventType, {
    RiderDto? riderDto,
  }) async {
    final event = EventTypeX.fromString(eventType);
    logger?.debug(
      'SubscriptionHandler: Order ${orderDto?.id ?? "none"} - $event',
    );

    switch (event) {
      case EventType.created:
      case EventType.updated:
        await Future.wait([
          if (orderDto != null) orderDao.upsertOrder(orderDto.toDriftCompanion()),
          if (riderDto != null)
            riderDao.upsertRider(riderDto.toDriftCompanion()),
        ]);
      case EventType.deleted:
        if (orderDto != null) {
          await orderDao.deleteOrder(orderDto.id);
        }
    }
  }

  @mustCallSuper
  Future<void> handleRiderUpdate(
    RiderDto riderDto,
    String eventType,
  ) async {
    final event = EventTypeX.fromString(eventType);
    logger?.debug('SubscriptionHandler: Rider ${riderDto.id} - $event');

    switch (event) {
      case EventType.created:
      case EventType.updated:
        await riderDao.upsertRider(riderDto.toDriftCompanion());
      case EventType.deleted:
        await riderDao.deleteRider(riderDto.id);
    }
  }
}
