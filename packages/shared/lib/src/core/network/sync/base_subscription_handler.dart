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
    String eventType,
    OrderDto? orderDto, {
    RiderDto? riderDto,
  }) async {
    final event = SubscriptionEventTypeX.fromString(eventType);
    logger?.debug(
      'SubscriptionHandler: Order ${orderDto?.id ?? "none"} - $event',
    );

    switch (event) {
      case SubscriptionEventType.CREATED:
      case SubscriptionEventType.UPDATED:
      case SubscriptionEventType.ASSIGNED:
      case SubscriptionEventType.STATUS_CHANGED:
        if (orderDto != null) {
          await orderDao.upsertOrder(orderDto.toDriftCompanion());
        }
        if (riderDto != null) {
          await riderDao.upsertRider(riderDto.toDriftCompanion());
        }
      case SubscriptionEventType.DELETED:
        if (orderDto != null) {
          await orderDao.deleteOrder(orderDto.id);
        }
      case SubscriptionEventType.LOCATION_UPDATED:
        if (riderDto != null) {
          await riderDao.upsertRider(riderDto.toDriftCompanion());
        }
    }

  }

  @mustCallSuper
  Future<void> handleRiderUpdate(RiderDto riderDto, String eventType) async {
    final event = SubscriptionEventTypeX.fromString(eventType);
    logger?.debug('SubscriptionHandler: Rider ${riderDto.id} - $event');

    switch (event) {
      case SubscriptionEventType.CREATED:
      case SubscriptionEventType.UPDATED:
      case SubscriptionEventType.STATUS_CHANGED:
      case SubscriptionEventType.ASSIGNED:
      case SubscriptionEventType.LOCATION_UPDATED:
        await riderDao.upsertRider(riderDto.toDriftCompanion());
      case SubscriptionEventType.DELETED:
        await riderDao.deleteRider(riderDto.id);
    }
  }
}
