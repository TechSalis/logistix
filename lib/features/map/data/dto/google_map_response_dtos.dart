import 'package:equatable/equatable.dart';
import 'package:logistix/core/domain/entities/address.dart';
import 'package:logistix/core/domain/entities/coordinate.dart';

class Place extends Equatable {
  final String id;
  final String name;

  const Place({required this.id, required this.name});
  
  @override
  List<Object?> get props => [id, name];
}

class PlaceModel extends Place {
  const PlaceModel({required super.id, required super.name});

  factory PlaceModel.search(Map<String, dynamic> json) {
    return PlaceModel(id: json['id'], name: json['displayName']['text']);
  }
  factory PlaceModel.suggestion(Map<String, dynamic> json) {
    return PlaceModel(id: json['placeId'], name: json['text']['text']);
  }
  factory PlaceModel.geocode(Map<String, dynamic> json) {
    return PlaceModel(id: json['place_id'], name: json['formatted_address']);
  }
}

class PlaceDetails extends Place {
  const PlaceDetails({
    required super.id,
    required super.name,
    required this.address,
  });

  final Address address;


  @override
  List<Object?> get props => [...super.props, address];
}

class PlaceDetailsModel extends PlaceDetails {
  const PlaceDetailsModel({
    required super.id,
    required super.name,
    required super.address,
  });

  factory PlaceDetailsModel.place(Map<String, dynamic> json) {
    return PlaceDetailsModel(
      id: json['id'],
      name: json['displayName']['text'],
      address: Address(
        formatted: json['formattedAddress'],
        coordinates: Coordinates.fromMap(json['location']),
      ),
    );
  }
}
