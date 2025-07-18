import 'package:equatable/equatable.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/orders/domain/entities/base_order_data.dart';

base class Order extends BaseOrderData with EquatableMixin {
  final int refNumber;
  final OrderStatus orderStatus;
  final RiderData? rider;

  const Order({
    required super.orderType,
    required super.description,
    super.pickup,
    super.dropoff,
    required super.price,
    required this.refNumber,
    required this.orderStatus,
    this.rider,
  });

  @override
  List<Object?> get props => [
    refNumber,
    orderType,
    pickup,
    dropoff,
    description,
    price,
    orderStatus,
    rider,
  ];
}
