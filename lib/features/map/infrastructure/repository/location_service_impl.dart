import 'package:geolocator/geolocator.dart';
import 'package:logistix/core/entities/coordinate.dart';
import 'package:logistix/features/map/domain/repository/location_service.dart';

class LocalGeoLocationServiceImpl extends GeoLocationService {
  @override
  Future<Coordinates> getUserCoordinates() async {
    final location = await Geolocator.getCurrentPosition();
    return Coordinates(location.latitude, location.longitude);
  }

  @override
  Stream<Coordinates> getUserCoordinatesStream() {
    return Geolocator.getPositionStream().map((location) {
      return Coordinates(location.latitude, location.longitude);
    });
  }
}
