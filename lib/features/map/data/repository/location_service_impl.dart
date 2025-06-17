import 'package:geolocator/geolocator.dart';
import 'package:logistix/features/map/domain/entities/coordinate.dart';
import 'package:logistix/features/map/domain/repository/location_service.dart';

class LocationServiceImpl extends LocationService {
  @override
  Future<Coordinates> getCoordinates() async {
    final location = await Geolocator.getCurrentPosition();
    return Coordinates(location.latitude, location.longitude);
  }
}
