import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_create_input.freezed.dart';
part 'order_create_input.g.dart';

@freezed
class OrderCreateInput with _$OrderCreateInput {
  const factory OrderCreateInput({
    required String pickupAddress,
    String? dropOffAddress,
    String? description,
    double? codAmount,
    String? customerPhone,
    String? riderId,
  }) = _OrderCreateInput;

  factory OrderCreateInput.fromJson(Map<String, dynamic> json) =>
      _$OrderCreateInputFromJson(json);
}
