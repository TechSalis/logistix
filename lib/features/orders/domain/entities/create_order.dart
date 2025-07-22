import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/orders/domain/entities/base_order_data.dart';

class OrderFilter {
  final Iterable<OrderType>? types;
  final Iterable<OrderStatus>? statuses;

  const OrderFilter({this.types, this.statuses});

  Map<String, dynamic> toJson() => {
    'order_types': types?.map((e) => e.name),
    'order_statuses': statuses?.map((e) => e.name),
  };
}

final class CreateOrderData extends BaseOrderData {
  final Map<String, dynamic>? extras;

  const CreateOrderData({
    required super.pickup,
    required super.dropoff,
    super.price,
    required super.orderType,
    required super.description,
    this.extras,
  });

  CreateOrderData copyWith({
    Address? pickup,
    Address? dropoff,
    double? price,
    OrderType? orderType,
    String? description,
    Map<String, dynamic>? extras,
  }) {
    return CreateOrderData(
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      price: price ?? this.price,
      orderType: orderType ?? this.orderType,
      description: description ?? this.description,
      extras: extras ?? this.extras,
    );
  }

  @override
  Map<String, dynamic> toJson() => super.toJson()..['extras'] = extras;
}
