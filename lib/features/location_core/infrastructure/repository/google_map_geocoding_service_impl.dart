import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/features/location_core/domain/repository/geocoding_service.dart';
import 'package:logistix/features/location_core/infrastructure/datasources/google_maps_datasource.dart';

class GoogleGeocodingServiceImpl implements GeocodingService {
  final GoogleMapsDatasource _api;
  GoogleGeocodingServiceImpl(this._api);

  @override
  Future<Address?> getAddress(Coordinates coordinate) async {
    try {
      final data = (await _api.getAddressProperties(coordinate)).firstOrNull;

      if (data == null) return null;
      return Address(data.name, coordinates: coordinate);
    } catch (e) {
      throw const NetworkError('Couldn\'t get address');
    }
  }
}
