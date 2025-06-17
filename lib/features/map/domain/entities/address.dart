import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final String formatted;
  final num latitude;
  final num longitude;

  const Address({
    required this.formatted,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() => formatted;
  
  @override
  List<Object?> get props => [formatted, latitude, longitude];
}
