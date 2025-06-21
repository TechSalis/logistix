import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/features/map/data/datasources/__mapbox_datasource.dart';
import 'package:logistix/core/domain/entities/address.dart';
import 'package:logistix/core/domain/entities/coordinate.dart';
import 'package:logistix/features/map/domain/repository/geocoding_service.dart';

class MapBoxGeocodingServiceImpl implements GeocodingService {
  final MapBoxDatasource _api;
  MapBoxGeocodingServiceImpl(this._api);

  @override
  Future<Address> getAddress(Coordinates coordinates) async {
    try {
      final data = await _api.getAddressProperties(coordinates);

      return Address(
        formatted: data.first.fullAddress,
        coordinates: data.first.coordinates,
      );
    } catch (e) {
      throw AppError(error: 'Failed to get address: $e');
    }
  }
}
