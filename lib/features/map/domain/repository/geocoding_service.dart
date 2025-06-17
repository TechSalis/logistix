
import 'package:logistix/features/map/domain/entities/address.dart';
import 'package:logistix/features/map/domain/entities/coordinate.dart';

abstract class GeocodingService {
  Future<Address> getAddress(Coordinates coordinate);
}
