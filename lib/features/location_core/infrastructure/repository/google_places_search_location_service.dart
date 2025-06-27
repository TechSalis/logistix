import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/features/location_core/domain/entities/place.dart';
import 'package:logistix/features/location_core/domain/repository/location_service.dart';
import 'package:logistix/features/location_core/domain/repository/search_location_service.dart';
import 'package:logistix/features/location_core/infrastructure/datasources/google_places_datasource.dart';

class GooglePlacesSearchLocationServiceImpl extends SearchLocationService {
  GooglePlacesSearchLocationServiceImpl(this._api, this._locationApi);
  final GooglePlacesDatasource _api;
  final GeoLocationService _locationApi;

  // Keeps a memory store of fetched address place-ids.
  //These would be needed when fetching place details of an address
  static final Map<Address, String> _addressPlaceIds = {};

  @override
  Future<List<Address>> search(String text) async {
    try {
      final data = await _api.suggestions(
        text,
        await _locationApi.getUserCoordinates(),
      );

      // Only store place ids of newest addresses
      _addressPlaceIds.clear();
      return data.map((e) {
        final address = Address(e.name, coordinates: null);

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
