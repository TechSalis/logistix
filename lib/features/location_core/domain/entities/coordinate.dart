import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'coordinate.g.dart';

@JsonSerializable(createToJson: true, createFactory: false)
class Coordinates extends Equatable {
  @JsonKey(name: 'lat')
  final double latitude;

  @JsonKey(name: 'lng')
  final double longitude;

  const Coordinates(this.latitude, this.longitude);

  @override
  List<Object?> get props => [latitude, longitude];

  factory Coordinates.fromJson(Map<String, dynamic> json) =>
      _$CoordinatesFromJson(json);

  Map<String, dynamic> toJson() => _$CoordinatesToJson(this);
}
