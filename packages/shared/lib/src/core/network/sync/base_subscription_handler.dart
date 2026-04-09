import 'package:bootstrap/interfaces/logger/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

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
    final event = SubscriptionEventTypeX.fromString(eventType);
    logger?.debug(
      'SubscriptionHandler: Order ${orderDto?.id ?? "none"} - $event',
    );

    switch (event) {
      case SubscriptionEventType.created:
      case SubscriptionEventType.updated:
      case SubscriptionEventType.assigned:
      case SubscriptionEventType.status_changed:
        await Future.wait([
          if (orderDto != null) orderDao.upsertOrder(orderDto.toDriftCompanion()),
          if (riderDto != null)
            riderDao.upsertRider(riderDto.toDriftCompanion()),
        ]);
      case SubscriptionEventType.deleted:
        if (orderDto != null) {
          await orderDao.deleteOrder(orderDto.id);
        }
      case SubscriptionEventType.location_updated:
        if (riderDto != null) {
          await riderDao.upsertRider(riderDto.toDriftCompanion());
        }
    }
  }

  @mustCallSuper
  Future<void> handleRiderUpdate(
    RiderDto riderDto,
    String eventType,
  ) async {
    final event = SubscriptionEventTypeX.fromString(eventType);
    logger?.debug('SubscriptionHandler: Rider ${riderDto.id} - $event');

    switch (event) {
      case SubscriptionEventType.created:
      case SubscriptionEventType.updated:
      case SubscriptionEventType.status_changed:
      case SubscriptionEventType.assigned:
      case SubscriptionEventType.location_updated:
        await riderDao.upsertRider(riderDto.toDriftCompanion());
      case SubscriptionEventType.deleted:
        await riderDao.deleteRider(riderDto.id);
    }
  }
}
