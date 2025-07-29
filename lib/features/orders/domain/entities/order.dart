import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logistix/core/theme/colors.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/orders/domain/entities/base_order_data.dart';

base class Order extends BaseOrderData with EquatableMixin {
  final String orderId;
  final int refNumber;
  final OrderStatus status;
  final RiderData? rider;

  const Order({
    required this.orderId,
    required this.refNumber,
    required super.orderType,
    required super.description,
    super.pickup,
    super.dropoff,
    required super.price,
    required this.status,
    this.rider,
  });

  Order copyWith({OrderStatus? status}) {
    return Order(
      orderId: orderId,
      refNumber: refNumber,
      orderType: orderType,
      description: description,
      pickup: pickup,
      dropoff: dropoff,
      price: price,
      status: status ?? this.status,
      rider: rider,
    );
  }

  @override
  List<Object?> get props => [
    orderId,
    refNumber,
    orderType,
    pickup,
    dropoff,
    description,
    price,
    status,
    rider,
  ];
}

/// In sync with data values in the backend
enum OrderStatus {
  pending,
  accepted,
  onTheWay,
  delivered,
  cancelled;

  String get label => switch (this) {
    OrderStatus.pending => 'Pending',
    OrderStatus.accepted => 'Accepted',
    OrderStatus.onTheWay => 'On the way',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.cancelled => 'Cancelled',
  };
  Color get color => switch (this) {
    OrderStatus.pending => AppColors.blueGreyMat,
    OrderStatus.accepted => Colors.blue,
    OrderStatus.onTheWay => Colors.blue,
    OrderStatus.delivered => Colors.green,
    OrderStatus.cancelled => Colors.red,
  };
}
