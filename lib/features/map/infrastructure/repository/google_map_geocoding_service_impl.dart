import 'package:logistix/core/entities/address.dart';
import 'package:logistix/core/entities/coordinate.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/features/map/domain/repository/geocoding_service.dart';
import 'package:logistix/features/map/infrastructure/datasources/google_maps_datasource.dart';

class GoogleGeocodingServiceImpl implements GeocodingService {
  final GoogleMapsDatasource _api;
  GoogleGeocodingServiceImpl(this._api);

  @override
  Future<Address?> getAddress(Coordinates coordinate) async {
    try {
      final data = (await _api.getAddressProperties(coordinate)).firstOrNull;

      if (data == null) return null;
      return Address(formatted: data.name, coordinates: coordinate);
    } catch (e) {
      throw AppError(error: 'Failed to get address: $e');
    }
  }
}
