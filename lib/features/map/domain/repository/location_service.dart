import 'package:logistix/core/entities/coordinate.dart';

abstract class GeoLocationService {
  Future<Coordinates> getUserCoordinates();
  Stream<Coordinates> getUserCoordinatesStream();
}