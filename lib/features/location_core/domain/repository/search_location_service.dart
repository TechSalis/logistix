
import 'package:logistix/features/location_core/domain/entities/place.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';

abstract class SearchLocationService {
  Future<List<Address>> search(String text);
  Future<PlaceDetails> place(Address address);
}