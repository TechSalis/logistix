import 'package:logistix/features/location/domain/entities/address.dart';
import 'package:logistix/features/location/domain/entities/coordinate.dart';

abstract class GeocodingService {
  Future<Address?> getAddress(Coordinates coordinates);
}
