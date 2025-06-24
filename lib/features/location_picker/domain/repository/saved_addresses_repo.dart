import 'package:logistix/features/location/domain/entities/address.dart';

abstract class SavedAddressesRepo {
  Future<List<Address>> getSavedAdresses([int? count = 5]);
  Future<void> saveAddress(Address address);
}
