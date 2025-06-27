import 'package:logistix/features/location_core/domain/entities/coordinate.dart';

abstract class GeoLocationService {
  Future<Coordinates> getUserCoordinates();
  Stream<Coordinates> getUserCoordinatesStream();
}