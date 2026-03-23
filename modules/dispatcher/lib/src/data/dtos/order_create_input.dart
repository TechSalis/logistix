import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'order_create_input.freezed.dart';
part 'order_create_input.g.dart';

@freezed
class OrderCreateInput with _$OrderCreateInput {
  const factory OrderCreateInput({
    required String dropOffAddress,
    String? dropOffPlaceId,
    String? pickupAddress,
    String? pickupPlaceId,
    String? description,
    double? codAmount,
    String? pickupPhone,
    String? dropOffPhone,
    String? riderId,
    // ignore: invalid_annotation_target
    @JsonKey(includeFromJson: false, includeToJson: false) Rider? rider,
  }) = _OrderCreateInput;

  factory OrderCreateInput.fromJson(Map<String, dynamic> json) =>
      _$OrderCreateInputFromJson(json);
}
