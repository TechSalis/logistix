import 'package:equatable/equatable.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';

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

  Map<String, dynamic> toJson() => {
    'name': name,
    if (coordinates != null) 'coordinates': coordinates!.toJson(),
  };

  @override
  String toString() => 'Address($name, $coordinates)';

  @override
  List<Object?> get props => [name, coordinates];
}
