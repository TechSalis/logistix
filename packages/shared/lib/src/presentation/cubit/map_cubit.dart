import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared/src/presentation/cubit/map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(const MapState.initial());

  Future<void> requestLocationPermission() async {
    emit(const MapState.checkingPermission());

    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(
          const MapState.permissionDenied(
            message:
                'Location services are disabled.'
                ' Please enable location services in your device settings.',
          ),
        );
        return;
      }

      // Check current permission status
      var permission = await Geolocator.checkPermission();

      // Request permission if denied
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(
            const MapState.permissionDenied(
              message:
                  'Location permission denied.'
                  ' Please grant location access to use the map.',
            ),
          );
          return;
        }
      }

      // Handle permanently denied permission
      if (permission == LocationPermission.deniedForever) {
        emit(
          const MapState.permissionDenied(
            message:
                'Location permission permanently denied.'
                ' Please enable location access in app settings.',
          ),
        );
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          timeLimit: Duration(seconds: 3),
        ),
      );

      emit(MapState.ready(currentPosition: position));
    } catch (e) {
      emit(const MapState.permissionDenied(message: 'Failed to get location'));
    }
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();
}
