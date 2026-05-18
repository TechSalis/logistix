import 'package:bootstrap/interfaces/store/store.dart';
import 'package:rider/src/features/deliveries/data/dtos/rider_metrics_dto.dart';
import 'package:shared/shared.dart';

class RiderSubscriptionHandler extends BaseSubscriptionHandler {
  RiderSubscriptionHandler({
    required super.deliveryDao,
    required super.riderDao,
    required ObjectStore<RiderMetricsDto> metricsStore,
    super.logger,
  }) : _metricsStore = metricsStore;

  final ObjectStore<RiderMetricsDto> _metricsStore;

  @override
  Future<void> handleDeliveryUpdate(
    String eventType,
    DeliveryDto? deliveryDto, {
    RiderDto? riderDto,
    RiderMetricsDto? riderMetrics,
  }) async {
    await super.handleDeliveryUpdate(eventType, deliveryDto, riderDto: riderDto);

    if (riderMetrics != null) {
      await _metricsStore.set(riderMetrics);
    }
  }
}
