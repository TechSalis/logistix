import 'package:geolocator/geolocator.dart';
import 'package:logistix/features/permission/domain/repository/settings_service.dart';

class LocationSettingsImpl extends SettingsService {
  @override
  Future<bool> open() => Geolocator.openLocationSettings();
}
