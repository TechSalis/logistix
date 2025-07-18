import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';

class OrderFilter {
  final Iterable<OrderType>? types;
  final Iterable<OrderStatus>? statuses;

  const OrderFilter({this.types, this.statuses});

  Map<String, dynamic> toJson() => {
    'types': types?.map((e) => e.name).toList(),
    'statuses': statuses?.map((e) => e.name).toList(),
  };
}

class CreateOrderData {
  final Address? pickUp, dropOff;
  final double price;
  final OrderType type;
  final String description;

  const CreateOrderData({
    required this.pickUp,
    required this.dropOff,
    required this.price,
    required this.type,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'pickUp': pickUp?.toJson(),
    'dropOff': dropOff?.toJson(),
    'price': price,
    'type': type.name,
    'description': description,
  };
}
