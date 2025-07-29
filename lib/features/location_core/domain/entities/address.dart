import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';

part 'address.g.dart';

@JsonSerializable(createFactory: false)
class Address extends Equatable {
  final String name;
  final Coordinates? coordinates;

  const Address(this.name, {this.coordinates});
  factory Address.empty() => const Address('', coordinates: null);

  Address copyWith({String? name, Coordinates? coordinates}) {
    return Address(
      name ?? this.name,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  @override
  List<Object?> get props => [name, coordinates];

  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
