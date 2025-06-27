import 'package:equatable/equatable.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';

class Address extends Equatable {
  final String formatted;
  final Coordinates? coordinates;

  const Address(this.formatted, {this.coordinates});

  factory Address.empty() => const Address('', coordinates: null);

  Address copyWith({String? formatted, Coordinates? coordinates}) {
    return Address(
      formatted ?? this.formatted,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  @override
  String toString() => formatted;

  @override
  List<Object?> get props => [formatted, coordinates];
}
