import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';

part 'address_coordinates_model.g.dart';

@HiveType(typeId: 0)
// ignore: must_be_immutable
class AddressModel extends Address with HiveObjectMixin {
  AddressModel(this.name, {this.coordinates})
    : super(name, coordinates: coordinates);

  @override
  @HiveField(0)
  // ignore: overridden_fields
  final String name;

  @override
  @HiveField(1)
  // ignore: overridden_fields
  final Coordinates? coordinates;

  factory AddressModel.fromJson(Map<String, dynamic> map) {
    return AddressModel(
      map['name'],
      coordinates:
          map['coordinates'] == null
              ? null
              : CoordinatesModel.fromJson(map['coordinates']),
    );
  }

  factory AddressModel.address(Address address) {
    return AddressModel(
      address.name,
      coordinates: address.coordinates,
    );
  }
}

@HiveType(typeId: 1)
// ignore: must_be_immutable
class CoordinatesModel extends Coordinates with HiveObjectMixin {
  CoordinatesModel(this.latitude, this.longitude) : super(latitude, longitude);

  @override
  @HiveField(0)
  // ignore: overridden_fields
  final double latitude;

  @override
  @HiveField(1)
  // ignore: overridden_fields
  final double longitude;

  factory CoordinatesModel.fromJson(Map<String, dynamic> map) {
    return CoordinatesModel(map['lat'], map['lng']);
  }
}
