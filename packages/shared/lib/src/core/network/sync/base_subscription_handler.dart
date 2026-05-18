import 'package:flutter/foundation.dart';
import 'package:shared/shared.dart';

abstract class BaseSubscriptionHandler {
  BaseSubscriptionHandler({
    required this.deliveryDao,
    required this.riderDao,
    this.logger,
  });

  @protected
  final DeliveryDao deliveryDao;
  @protected
  final RiderDao riderDao;

  @protected
  final Logger? logger;

  @mustCallSuper
  Future<void> handleDeliveryUpdate(
    String eventType,
    DeliveryDto? deliveryDto, {
    RiderDto? riderDto,
  }) async {
    final event = SubscriptionEventTypeX.fromString(eventType);
    logger?.debug(
      'SubscriptionHandler: Delivery ${deliveryDto?.id ?? "none"} - $event',
    );

    switch (event) {
      case SubscriptionEventType.CREATED:
      case SubscriptionEventType.UPDATED:
      case SubscriptionEventType.ASSIGNED:
      case SubscriptionEventType.STATUS_CHANGED:
        if (deliveryDto != null) {
          await deliveryDao.upsertDelivery(deliveryDto.toDriftCompanion());
        }
        if (riderDto != null) {
          await riderDao.upsertRider(riderDto.toDriftCompanion());
        }
      case SubscriptionEventType.DELETED:
        if (deliveryDto != null) {
          await deliveryDao.deleteDelivery(deliveryDto.id);
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
