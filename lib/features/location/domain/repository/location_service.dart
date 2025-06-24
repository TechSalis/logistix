import 'package:logistix/features/location/domain/entities/coordinate.dart';

abstract class GeoLocationService {
  Future<Coordinates> getUserCoordinates();
  Stream<Coordinates> getUserCoordinatesStream();
}