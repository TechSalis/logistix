import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/features/map/data/datasources/google_maps_datasource.dart';
import 'package:logistix/core/domain/entities/address.dart';
import 'package:logistix/core/domain/entities/coordinate.dart';
import 'package:logistix/features/map/domain/repository/geocoding_service.dart';

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
