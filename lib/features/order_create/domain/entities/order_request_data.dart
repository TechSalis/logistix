import 'package:equatable/equatable.dart';
import 'package:logistix/features/orders/domain/entities/base_order_data.dart';
import 'package:logistix/features/order_create/domain/entities/create_order.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';

base class OrderRequestData extends BaseOrderData {
  const OrderRequestData({
    required super.description,
    required super.pickup,
    required super.dropoff,
    required super.orderType,
  });

  CreateOrderData toCreateOrder() {
    return CreateOrderData(
      description: description,
      pickup: pickup,
      dropoff: dropoff,
      orderType: orderType,
    );
  }

  Order toOrder({required String orderId, required int refNumber}) => Order(
    orderId: orderId,
    refNumber: refNumber,
    orderType: orderType,
    description: description,
    pickup: pickup,
    dropoff: dropoff,
    price: price,
    status: OrderStatus.pending,
    rider: null,
  );
}

final class DeliveryRequestData extends OrderRequestData with EquatableMixin {
  final Iterable<String>? imageUrls;

  const DeliveryRequestData({
    required super.description,
    required super.pickup,
    required super.dropoff,
    this.imageUrls,
  }) : super(orderType: OrderType.delivery);

  @override
  List<Object?> get props => [...super.props, imageUrls];

  @override
  CreateOrderData toCreateOrder() {
    return super.toCreateOrder().copyWith(
      extras: {
        if (imageUrls?.isNotEmpty ?? false) 'image_urls': imageUrls!.toList(),
      },
    );
  }
}
