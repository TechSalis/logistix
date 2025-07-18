import 'package:equatable/equatable.dart';
import 'package:logistix/features/orders/domain/entities/base_order_data.dart';
import 'package:logistix/features/orders/domain/entities/create_order.dart';

sealed class OrderRequestData extends BaseOrderData {
  const OrderRequestData({
    required super.description,
    required super.pickup,
    required super.dropoff,
    required super.orderType,
  });

  CreateOrderData toNewOrder() {
    return CreateOrderData(
      description: description,
      pickup: pickup,
      dropoff: dropoff,
      orderType: orderType,
    );
  }
}

final class DeliveryRequestData extends OrderRequestData with EquatableMixin {
  final Iterable<String> imagePaths;

  const DeliveryRequestData({
    required super.description,
    required super.pickup,
    required super.dropoff,
    this.imagePaths = const [],
  }) : super(orderType: OrderType.delivery);

  @override
  List<Object?> get props => [...super.props, imagePaths];

  @override
  CreateOrderData toNewOrder() {
    return super.toNewOrder().copyWith(extras: {'image_paths': imagePaths});
  }
}

final class FoodRequestData extends OrderRequestData with EquatableMixin {
  const FoodRequestData({
    required super.description,
    required super.pickup,
    required super.dropoff,
  }) : super(orderType: OrderType.food);
}
