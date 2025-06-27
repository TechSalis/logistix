import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';

abstract class GeocodingService {
  Future<Address?> getAddress(Coordinates coordinates);
}
