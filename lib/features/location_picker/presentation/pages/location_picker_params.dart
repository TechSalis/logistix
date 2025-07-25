import 'package:json_annotation/json_annotation.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';

part 'location_picker_params.g.dart';

@JsonSerializable()
class LocationPickerPageParams {
  const LocationPickerPageParams({this.initialLocation, this.heroTag});

  final Address? initialLocation;
  final String? heroTag;

  factory LocationPickerPageParams.fromJson(Map<String, dynamic> json) =>
      _$LocationPickerPageParamsFromJson(json);

  Map<String, dynamic> toJson() => _$LocationPickerPageParamsToJson(this);
}
