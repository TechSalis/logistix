import 'package:equatable/equatable.dart';
import 'package:logistix/core/domain/entities/coordinate.dart';

class Address extends Equatable {
  final String formatted;
  final Coordinates? coordinates;

  const Address({required this.formatted, required this.coordinates});
  factory Address.empty() => Address(formatted: '', coordinates: null);

  Address copyWith({String? formatted, Coordinates? coordinates}) {
    return Address(
      coordinates: coordinates ?? this.coordinates,
      formatted: formatted ?? this.formatted,
    );
  }

  @override
  String toString() => formatted;

  @override
  List<Object?> get props => [formatted, coordinates];
}
