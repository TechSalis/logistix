
import 'package:equatable/equatable.dart';
import 'package:logistix/core/entities/address.dart';


class Place extends Equatable {
  final String id;
  final String name;

  const Place({required this.id, required this.name});
  
  @override
  List<Object?> get props => [id, name];
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