import 'package:equatable/equatable.dart';

class Coordinates extends Equatable {
  final double latitude;
  final double longitude;

  const Coordinates(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];

  @override
  String toString() {
    return 'Coordinates($latitude, $longitude)';
  }

  Map<String, dynamic> toMap() => {
    'latitude': latitude,
    'longitude': longitude,
  };
}
