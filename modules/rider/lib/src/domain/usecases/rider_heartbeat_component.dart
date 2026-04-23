import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:rider/src/data/datasources/rider_remote_datasource.dart';
import 'package:rider/src/data/dtos/rider_heartbeat_request.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/bloc/rider_event.dart';
import 'package:shared/shared.dart';

/// Component that handles status heartbeats and distance-aware location updates.
class RiderHeartbeatComponent extends SessionComponent {
  RiderHeartbeatComponent({
    required RiderRemoteDataSource dataSource,
    required RiderDao riderDao,
    required RiderBloc riderBloc,
    this.heartbeatInterval = const Duration(seconds: 60),
    this.distanceThreshold = 50, // meters
  }) : _dataSource = dataSource,
       _riderDao = riderDao,
       _riderBloc = riderBloc;

  final RiderRemoteDataSource _dataSource;
  final RiderDao _riderDao;
  final RiderBloc _riderBloc;
  final Duration heartbeatInterval;
  final int distanceThreshold;

  Timer? _heartbeatTimer;
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastSentPosition;

  @override
  String get id => 'rider_heartbeat';

  @override
  Future<void> start() async {
    // 1. Status Heartbeat (Time-based: 60s)
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) => _sendPulse());

    // 2. Hardware-Throttled Movement (Distance-based)
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: distanceThreshold,
      ),
    ).listen((pos) => _sendPulse(position: pos));

    // Initial pulse
    await _sendPulse();
  }

  Future<void> _sendPulse({Position? position}) async {
    // Hierarchical Logic:
    // - Use position if provided (50m hardware trigger).
    // - If not provided (60s timer), only use GPS if we've moved > 2m (Micro-movement guard).
    Position? posToSend = position;

    if (posToSend == null && _lastSentPosition != null) {
      final currentPos = await Geolocator.getLastKnownPosition();
      if (currentPos != null) {
        final distance = Geolocator.distanceBetween(
          _lastSentPosition!.latitude,
          _lastSentPosition!.longitude,
          currentPos.latitude,
          currentPos.longitude,
        );
        if (distance >= 2.0) {
          posToSend = currentPos;
        }
      }
    }

    if (posToSend != null) {
      _lastSentPosition = posToSend;
    }

    try {
      final riderDto = await _dataSource.sendHeartbeat(
        RiderHeartbeatRequest(
          lat: posToSend?.latitude,
          lng: posToSend?.longitude,
        ),
      );

      if (_riderBloc.isClosed) return;

      if (posToSend != null) {
        _riderBloc.add(RiderEvent.locationUpdated(posToSend));
      }

      await _riderDao.upsertRider(riderDto.toDriftCompanion());
      final status = RiderStatusX.fromString(riderDto.status);
      _riderBloc.add(RiderEvent.statusChanged(status));
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    _heartbeatTimer?.cancel();
    _positionSubscription?.cancel();
    _heartbeatTimer = null;
    _positionSubscription = null;
  }
}
