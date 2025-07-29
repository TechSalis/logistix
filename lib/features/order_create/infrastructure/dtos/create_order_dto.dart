import 'package:json_annotation/json_annotation.dart';

part 'create_order_dto.g.dart';

@JsonSerializable(
  createToJson: false,
  fieldRename: FieldRename.snake,
)
class CreateOrderResponse {
  final String orderId;
  final int refNumber;

  const CreateOrderResponse({required this.orderId, required this.refNumber});

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateOrderResponseFromJson(json);
}
