import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:rider/src/data/datasources/rider_remote_datasource.dart';
import 'package:rider/src/data/dtos/rider_heartbeat_request.dart';
import 'package:rider/src/presentation/bloc/rider_bloc.dart';
import 'package:rider/src/presentation/bloc/rider_event.dart';
import 'package:shared/shared.dart';

/// Component that periodically reports rider location and updates status.
class RiderHeartbeatComponent extends SessionComponent {
  RiderHeartbeatComponent({
    required RiderRemoteDataSource dataSource,
    required RiderDao riderDao,
    required RiderBloc riderBloc,
    this.interval = const Duration(seconds: 30),
  }) : _dataSource = dataSource,
       _riderDao = riderDao,
       _riderBloc = riderBloc;

  final RiderRemoteDataSource _dataSource;
  final RiderDao _riderDao;
  final RiderBloc _riderBloc;
  final Duration interval;

  Timer? _timer;

  @override
  String get id => 'rider_heartbeat';

  @override
  Future<void> start() async {
    // Initial heartbeat
    await _sendHeartbeat();

    // Periodic heartbeats
    _timer = Timer.periodic(interval, (_) => _sendHeartbeat());
  }

  Future<void> _sendHeartbeat() async {
    try {
      Position? position;
      try {
        final isEnabled = await Geolocator.isLocationServiceEnabled();
        if (isEnabled) {
          position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              timeLimit: Duration(seconds: 3),
            ),
          );
        }
      } catch (_) {}

      final riderDto = await _dataSource.sendHeartbeat(
        RiderHeartbeatRequest(
          lat: position?.latitude,
          lng: position?.longitude,
        ),
      );

      if (_riderBloc.isClosed) return;

      if (position != null) {
        _riderBloc.add(RiderEvent.locationUpdated(position));
      }

      await _riderDao.upsertRider(riderDto.toDriftCompanion());
      final status = RiderStatusX.fromString(riderDto.status);
      _riderBloc.add(RiderEvent.statusChanged(status));
    } catch (_) {}
  }

  @override
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
  }
}
