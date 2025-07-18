import 'package:geocoding/geocoding.dart' as geo;
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/features/location_core/domain/repository/geocoding_service.dart';

class LocalGeocodingServiceImpl implements GeocodingService {
  LocalGeocodingServiceImpl();

  @override
  Future<Address> getAddress(Coordinates coordinates) async {
    final placemarks = await geo.placemarkFromCoordinates(
      coordinates.latitude.toDouble(),
      coordinates.longitude.toDouble(),
    );

    if (placemarks.isEmpty) {
      throw const NetworkError('No address was found.');
    }

    final place = placemarks.first;
    final name = [
      if (place.name?.isNotEmpty ?? false) place.name,
      if (place.street?.isNotEmpty ?? false) place.street,
      if (place.locality?.isNotEmpty ?? false) place.locality,
      if (place.subAdministrativeArea?.isNotEmpty ?? false)
        place.subAdministrativeArea,
      if (place.administrativeArea?.isNotEmpty ?? false)
        place.administrativeArea,
    ];

    return Address(name.take(3).join(', ').trim(), coordinates: coordinates);
  }
}
