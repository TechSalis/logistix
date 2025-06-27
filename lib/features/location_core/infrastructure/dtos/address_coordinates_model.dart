import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';

part 'address_coordinates_model.g.dart';

@HiveType(typeId: 0)
// ignore: must_be_immutable
class AddressModel extends Address with HiveObjectMixin {
  AddressModel(this.formatted, {this.coordinates})
    : super(formatted, coordinates: coordinates);

  @override
  @HiveField(0)
  // ignore: overridden_fields
  final String formatted;

  @override
  @HiveField(1)
  // ignore: overridden_fields
  final CoordinatesModel? coordinates;

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      map['formatted'],
      coordinates:
          map['coordinates'] == null
              ? null
              : CoordinatesModel.fromMap(map['coordinates']),
    );
  }

  factory AddressModel.address(Address address) {
    return AddressModel(
      address.formatted,
      coordinates:
          address.coordinates == null
              ? null
              : CoordinatesModel.coordinates(address.coordinates!),
    );
  }

  Map<String, dynamic> toMap() => {
    'formatted': formatted,
    if (coordinates != null) 'coordinates': coordinates!.toMap(),
  };
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

  factory CoordinatesModel.fromMap(Map<String, dynamic> map) {
    return CoordinatesModel(map['latitude'], map['longitude']);
  }

  factory CoordinatesModel.coordinates(Coordinates coordinates) {
    return CoordinatesModel(coordinates.latitude, coordinates.longitude);
  }

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}
