import 'package:logistix/features/location_core/infrastructure/dtos/address_coordinates_model.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/rider/infrastructure/models/rider_data_dto.dart';

class OrderModel extends Order {
  const OrderModel({
    required super.type,
    required super.description,
    required super.price,
    required super.refNumber,
    required super.status,
    super.pickUp,
    super.dropOff,
    super.rider,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      description: json['description'],
      price: json['price'],
      refNumber: json['ref_number'],
      type: OrderType.values.byName(json['type']),
      status: OrderStatus.values.byName(json['status']),
      pickUp: json['pick_up'] != null ? AddressModel.fromJson(json['pick_up']) : null,
      dropOff: json['drop_off'] != null ? AddressModel.fromJson(json['drop_off']) : null,
      rider: json['rider'] != null ? RiderDataModel.fromJson(json['rider']) : null,
    );
  }
}
