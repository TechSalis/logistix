import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer_order_input.freezed.dart';
part 'customer_order_input.g.dart';

@freezed
class CustomerOrderInput with _$CustomerOrderInput {
  const factory CustomerOrderInput({
    required String dropOffAddress,
    required String dropOffPhone,
    required String description,
    String? dropOffPlaceId,
    String? pickupAddress,
    String? pickupPlaceId,
    String? pickupPhone,
    String? companyId,
  }) = _CustomerOrderInput;

  factory CustomerOrderInput.fromJson(Map<String, dynamic> json) =>
      _$CustomerOrderInputFromJson(json);
}
