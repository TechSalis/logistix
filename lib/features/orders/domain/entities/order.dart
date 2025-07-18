import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logistix/core/theme/colors.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/orders/domain/entities/order_repo_entiries.dart';

class Order extends CreateOrderData with EquatableMixin {
  final String refNumber;
  final OrderStatus status;
  final RiderData? rider;

  const Order({
    required super.type,
    required super.description,
    super.pickUp,
    super.dropOff,
    required super.price,

    required this.refNumber,
    required this.status,
    this.rider,
  });

  @override
  List<Object?> get props => [
    refNumber,
    type,
    pickUp,
    dropOff,
    description,
    price,
    status,
    rider,
  ];
}

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
    OrderStatus.pending => AppColors.grey800,
    OrderStatus.accepted => AppColors.orange,
    OrderStatus.onTheWay => Colors.blue,
    OrderStatus.delivered => Colors.green,
    OrderStatus.cancelled => Colors.red,
  };

  // bool get isFinal {
  //   return this == OrderStatus.delivered || this == OrderStatus.cancelled;
  // }

  // bool get isProcessing {
  //   return this == OrderStatus.accepted || this == OrderStatus.onTheWay;
  // }
}

enum OrderType {
  food,
  grocery,
  errands,
  delivery;

  String get label => switch (this) {
    delivery => 'Delivery',
    food => 'Food',
    grocery => 'Grocery',
    errands => 'Errands',
  };

  IconData get icon => switch (this) {
    delivery => Icons.moped,
    food => Icons.fastfood_outlined,
    grocery => Icons.shopping_cart,
    errands => Icons.local_mall_outlined,
  };

  Color get color => switch (this) {
    delivery => QuickActionColors.delivery,
    food => QuickActionColors.food,
    grocery => QuickActionColors.groceries,
    errands => QuickActionColors.errands,
  };
}
