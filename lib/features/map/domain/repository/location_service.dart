import 'package:logistix/core/domain/entities/coordinate.dart';

abstract class GeoLocationService {
  Future<Coordinates> getUserCoordinates();
  Stream<Coordinates> getUserCoordinatesStream();
}