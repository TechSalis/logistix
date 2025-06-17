import 'package:equatable/equatable.dart';

class Coordinates extends Equatable {
  final num latitude;
  final num longitude;

  const Coordinates(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];
}
