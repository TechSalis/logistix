import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

class RiderSessionManager {
  RiderSessionManager(
    this._riderRepository,
    this._eventStreamManager,
  );

  final RiderRepository _riderRepository;
  final AppEventStreamManager _eventStreamManager;

  StreamSubscription<void>? _orderAssignedSubscription;
  StreamSubscription<void>? _orderUpdatedSubscription;
  StreamSubscription<void>? _orderUnassignedSubscription;
  StreamSubscription<void>? _metricsSubscription;
  StreamSubscription<Position>? _locationSubscription;

  Timer? _rateLimitTimer;
  Position? _pendingPosition;

  Future<void> start({
    required String riderId,
    required void Function(Order) onOrderAssigned,
    required void Function(Order) onOrderUpdated,
    required void Function(String orderId) onOrderUnassigned,
    required void Function(RiderMetrics) onMetricsUpdated,
    required void Function(Position) onLocationUpdated,
  }) async {
    // Start the unified event stream for this rider
    await _eventStreamManager.startRiderStream(riderId);

    // Subscribe to order assigned events
    await _orderAssignedSubscription?.cancel();
    _orderAssignedSubscription = _eventStreamManager.orderAssigned.listen(
      (event) => onOrderAssigned(event.order),
    );

    // Subscribe to order updated events
    await _orderUpdatedSubscription?.cancel();
    _orderUpdatedSubscription = _eventStreamManager.riderOrderUpdated.listen(
      (event) => onOrderUpdated(event.order),
    );

    // Subscribe to order unassigned events
    await _orderUnassignedSubscription?.cancel();
    _orderUnassignedSubscription = _eventStreamManager.orderUnassigned.listen(
      (event) => onOrderUnassigned(event.orderId),
    );

    // Subscribe to metrics updates
    await _metricsSubscription?.cancel();
    _metricsSubscription = _eventStreamManager.riderMetricsUpdated.listen(
      (event) => onMetricsUpdated(event.metrics),
    );

    // Start location tracking
    await Geolocator.checkPermission();

    unawaited(_locationSubscription?.cancel());
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          onLocationUpdated(position);

          if (_rateLimitTimer?.isActive ?? false) {
            _pendingPosition = position;
            return;
          }

          _sendLocation(riderId, position);

          _rateLimitTimer = Timer(const Duration(seconds: 15), () {
            if (_pendingPosition != null) {
              _sendLocation(riderId, _pendingPosition!);
              _pendingPosition = null;
            }
          });
        });
  }

  void _sendLocation(String riderId, Position position) {
    _riderRepository.updateRiderLocation(
      riderId,
      position.latitude,
      position.longitude,
    );
  }

  void stop() {
    _orderAssignedSubscription?.cancel();
    _orderUpdatedSubscription?.cancel();
    _orderUnassignedSubscription?.cancel();
    _metricsSubscription?.cancel();
    _locationSubscription?.cancel();
    _rateLimitTimer?.cancel();
    _eventStreamManager.stop();
    _pendingPosition = null;
  }
}
