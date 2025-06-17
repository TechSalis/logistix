import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:logistix/features/map/domain/entities/address.dart';
import 'package:logistix/features/map/domain/entities/coordinate.dart';
import 'package:logistix/features/map/domain/repository/geocoding_service.dart';

class NativeGeocodingServiceImpl implements GeocodingService {
  @override
  Future<Address> getAddress(Coordinates coordinate) async {
    try {
      final placemarks = await geo.placemarkFromCoordinates(
        coordinate.latitude.toDouble(),
        coordinate.longitude.toDouble(),
      );

      if (placemarks.isEmpty) {
        throw Exception('No address found.');
      }

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

      return Address(
        formatted: formatted,
        latitude: coordinate.latitude,
        longitude: coordinate.longitude,
      );
    } on PlatformException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to get address: $e');
    }
  }
}
