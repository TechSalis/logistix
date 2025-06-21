
import 'package:logistix/features/map/data/dto/google_map_response_dtos.dart';
import 'package:logistix/core/domain/entities/address.dart';

abstract class SearchLocationService {
  Future<List<Address>> search(String text);
  Future<PlaceDetails> place(Address address);
}