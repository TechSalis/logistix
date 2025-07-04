import 'package:equatable/equatable.dart';

class Coordinates extends Equatable {
  final double latitude;
  final double longitude;

  const Coordinates(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];

  factory Coordinates.fromMap(Map<String, dynamic> map) {
    return Coordinates(map['latitude'] as double, map['longitude'] as double);
  }

  @override
  String toString() {
    return 'Coordinates($latitude, $longitude)';
  }
}
