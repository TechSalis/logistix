
import 'package:logistix/features/map/domain/entities/place.dart';
import 'package:logistix/core/entities/address.dart';

abstract class SearchLocationService {
  Future<List<Address>> search(String text);
  Future<PlaceDetails> place(Address address);
}