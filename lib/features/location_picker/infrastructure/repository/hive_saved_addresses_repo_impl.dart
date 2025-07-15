import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/core/utils/extensions/hive.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_picker/domain/repository/saved_addresses_repo.dart';
import 'package:logistix/features/location_core/infrastructure/dtos/address_coordinates_model.dart';

class HiveSavedAddressesRepoImpl extends SavedAddressesRepo {
  HiveSavedAddressesRepoImpl({this.maxLimit = 10});
  final int maxLimit;

  Future<Box<AddressModel>> get box {
    return Hive.openTrackedBox<AddressModel>('saved_addresses');
  }

  @override
  Future<List<Address>> getSavedAdresses([int? count]) async {
    return (count == null ? (await box).values : (await box).values.take(count))
        .cast<Address>()
        .toList();
  }

  @override
  Future<void> saveAddress(Address address) async {
    (await box).add(AddressModel.address(address));
  }
}
