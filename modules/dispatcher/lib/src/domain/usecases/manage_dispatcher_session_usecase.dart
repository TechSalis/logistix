import 'dart:async';

import 'package:shared/shared.dart';

class DispatcherSessionManager {
  DispatcherSessionManager(this._eventStreamManager);

  final AppEventStreamManager _eventStreamManager;

  StreamSubscription<void>? _orderCreatedSubscription;
  StreamSubscription<void>? _orderUpdatedSubscription;
  StreamSubscription<void>? _riderLocationSubscription;
  StreamSubscription<void>? _riderStatusSubscription;
  StreamSubscription<void>? _metricsSubscription;

  Future<void> start({
    required String companyId,
    required void Function(Order) onOrderCreated,
    required void Function(Order) onOrderUpdated,
    required void Function(String riderId, double lat, double lng, int? batteryLevel) onRiderLocationUpdated,
    required void Function(String riderId, String status) onRiderStatusChanged,
    required void Function(Metrics) onMetricsUpdated,
  }) async {
    // Start the unified event stream for this dispatcher
    await _eventStreamManager.startDispatcherStream(companyId);

    // Subscribe to order created events
    await _orderCreatedSubscription?.cancel();
    _orderCreatedSubscription = _eventStreamManager.orderCreated.listen(
      (event) => onOrderCreated(event.order),
    );

    // Subscribe to order updated events
    await _orderUpdatedSubscription?.cancel();
    _orderUpdatedSubscription = _eventStreamManager.dispatcherOrderUpdated.listen(
      (event) => onOrderUpdated(event.order),
    );

    // Subscribe to rider location updates
    await _riderLocationSubscription?.cancel();
    _riderLocationSubscription = _eventStreamManager.riderLocationUpdated.listen(
      (event) => onRiderLocationUpdated(
        event.riderId,
        event.lat,
        event.lng,
        event.batteryLevel,
      ),
    );

    // Subscribe to rider status changes
    await _riderStatusSubscription?.cancel();
    _riderStatusSubscription = _eventStreamManager.riderStatusChanged.listen(
      (event) => onRiderStatusChanged(event.riderId, event.status),
    );

    // Subscribe to metrics updates
    await _metricsSubscription?.cancel();
    _metricsSubscription = _eventStreamManager.metricsUpdated.listen(
      (event) => onMetricsUpdated(event.metrics),
    );
  }

  void stop() {
    _orderCreatedSubscription?.cancel();
    _orderUpdatedSubscription?.cancel();
    _riderLocationSubscription?.cancel();
    _riderStatusSubscription?.cancel();
    _metricsSubscription?.cancel();
    _eventStreamManager.stop();
  }
}
