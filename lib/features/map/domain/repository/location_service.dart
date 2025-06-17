import 'package:logistix/features/map/domain/entities/coordinate.dart';

abstract class LocationService {
  Future<Coordinates> getCoordinates();
}