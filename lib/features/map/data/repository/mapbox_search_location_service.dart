import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/features/map/data/datasources/__mapbox_datasource.dart';
import 'package:logistix/features/map/data/dto/google_map_response_dtos.dart';
import 'package:logistix/core/domain/entities/address.dart';
import 'package:logistix/features/map/domain/repository/search_location_service.dart';

class MapBoxSearchLocationServiceImpl extends SearchLocationService {
  final MapBoxDatasource _api;
  MapBoxSearchLocationServiceImpl(this._api);

  @override
  Future<List<Address>> search(String text) async {
    try {
      final data = await _api.search(text);

      return data.map((e) {
        return Address(
          formatted: e.fullAddress,
          coordinates: e.coordinates,
        );
      }).toList();
    } catch (e) {
      throw AppError(error: 'Unable to find address. $e');
    }
  }
  
  @override
  Future<PlaceDetails> place(Address address) {
    throw UnimplementedError();
  }
}
