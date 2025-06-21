import 'package:logistix/core/entities/coordinate.dart';

class GeoProperties {
  final String fullAddress;
  final String name;
  final Coordinates coordinates;
  // final String? placeFormatted;

  GeoProperties({
    required this.fullAddress,
    required this.name,
    required this.coordinates,
    // this.placeFormatted,
  });

  factory GeoProperties.fromMap(Map<String, dynamic> json) => GeoProperties(
    fullAddress: json['full_address'],
    name: json['name'],
    coordinates: Coordinates.fromMap(json['coordinates']),
    // placeFormatted: json['place_formatted'],
  );
}

class GeoSearchPlace {
  final String name;
  final String? poi;

  GeoSearchPlace({required this.name, required this.poi});

  factory GeoSearchPlace.fromMap(Map<String, dynamic> json) => GeoSearchPlace(
    name: json['name'],
    poi: (json['poi_category'] as List?)?.join(', '),
  );
}
