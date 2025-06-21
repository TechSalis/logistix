import 'package:logistix/core/entities/address.dart';
import 'package:logistix/core/entities/coordinate.dart';

abstract class GeocodingService {
  Future<Address?> getAddress(Coordinates coordinates);
}
