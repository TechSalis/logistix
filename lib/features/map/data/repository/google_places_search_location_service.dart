import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/features/map/data/datasources/google_places_datasource.dart';
import 'package:logistix/features/map/data/dto/google_map_response_dtos.dart';
import 'package:logistix/core/domain/entities/address.dart';
import 'package:logistix/features/map/domain/repository/search_location_service.dart';

class GooglePlacesSearchLocationServiceImpl extends SearchLocationService {
  GooglePlacesSearchLocationServiceImpl(this._api);
  final GooglePlacesDatasource _api;

  // Keeps a memory store of fetched address place-ids.
  //These would be needed when fetching place details of an address
  static final Map<Address, String> _addressPlaceIds = {};

  @override
  Future<List<Address>> search(String text) async {
    try {
      final data = await _api.suggestions(text);

      // Only store place ids of newest addresses
      _addressPlaceIds.clear();
      return data.map((e) {
        final address = Address(formatted: e.name, coordinates: null);

        _addressPlaceIds[address] = e.id;
        return address;
      }).toList();
    } catch (e) {
      throw AppError(error: 'Unable to find address. $e');
    }
  }

  @override
  Future<PlaceDetails> place(Address address) async {
    try {
      final data = await _api.place(_addressPlaceIds[address]!);
      
      return data;
    } catch (e) {
      throw AppError(error: 'Unable to find address. $e');
    }
  }
}
