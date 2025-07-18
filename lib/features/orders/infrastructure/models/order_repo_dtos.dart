import 'package:logistix/features/location_core/infrastructure/dtos/address_coordinates_model.dart';
import 'package:logistix/features/orders/domain/entities/base_order_data.dart';
import 'package:logistix/features/orders/domain/entities/order_responses.dart';
import 'package:logistix/features/rider/infrastructure/models/rider_data_dto.dart';

final class OrderModel extends Order {
  const OrderModel({
    required super.orderType,
    required super.description,
    required super.price,
    required super.refNumber,
    required super.orderStatus,
    super.pickup,
    super.dropoff,
    super.rider,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      description: json['description'],
      price: json['price'],
      refNumber: json['ref_number'],
      orderType: OrderType.values.byName(json['order_type']),
      orderStatus: OrderStatus.values.byName(
        json['order_status'] ?? OrderStatus.pending.name,
      ),
      pickup:
          json['pickup'] != null ? AddressModel.fromJson(json['pickup']) : null,
      dropoff:
          json['dropoff'] != null
              ? AddressModel.fromJson(json['dropoff'])
              : null,
      rider:
          json['rider'] != null ? RiderDataModel.fromJson(json['rider']) : null,
    );
  }
}
