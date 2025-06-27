import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/features/location_core/domain/repository/geocoding_service.dart';

class LocalGeocodingServiceImpl implements GeocodingService {
  LocalGeocodingServiceImpl();

  @override
  Future<Address> getAddress(Coordinates coordinates) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        coordinates.latitude.toDouble(),
        coordinates.longitude.toDouble(),
      );

      if (placemarks.isEmpty) throw AppError(error: 'No address found.');

      final place = placemarks.first;

      final formatted = [
        if (place.name?.isNotEmpty ?? false) place.name,
        if (place.street?.isNotEmpty ?? false) place.street,
        if (place.locality?.isNotEmpty ?? false) place.locality,
        if (place.subAdministrativeArea?.isNotEmpty ?? false)
          place.subAdministrativeArea,
        if (place.administrativeArea?.isNotEmpty ?? false)
          place.administrativeArea,
      ].take(3).join(', ');

      return Address(formatted.trim(), coordinates: coordinates);
    } on PlatformException {
      rethrow;
    } catch (e) {
      throw AppError(error: 'Failed to get address: $e');
    }
  }
}
