// lib/features/orders/domain/entities/order.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logistix/core/theme/colors.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/app/domain/entities/rider_data.dart';

class Order extends Equatable {
  final String id;
  final Address? pickUp, dropOff;
  final double price;
  final OrderType type;
  final OrderStatus status;
  final String description;
  final RiderData? rider;

  const Order({
    required this.id,
    required this.type,
    required this.price,
    required this.status,
    this.pickUp,
    this.dropOff,
    required this.description,
    this.rider,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    pickUp,
    dropOff,
    description,
    price,
    status,
    rider,
  ];
}

enum OrderStatus { pending, confirmed, enRoute, delivered, cancelled }

extension OrderStatusExt on OrderStatus {
  String get label => switch (this) {
    OrderStatus.pending => 'Pending',
    OrderStatus.confirmed => 'Confirmed',
    OrderStatus.enRoute => 'On the way',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.cancelled => 'Cancelled',
  };

  Color get color => switch (this) {
    OrderStatus.pending => Colors.grey.shade800,
    OrderStatus.confirmed => AppColors.orange,
    OrderStatus.enRoute => Colors.green,
    OrderStatus.delivered => Colors.green.shade700,
    OrderStatus.cancelled => Colors.red,
  };

  bool get isFinal {
    return this == OrderStatus.delivered || this == OrderStatus.cancelled;
  }

  bool get isProcessing {
    return this == OrderStatus.confirmed || this == OrderStatus.enRoute;
  }
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
    errands => Icons.list_alt,
  };

  Color get color => switch (this) {
    delivery => AppColors.blueGreyMaterial,
    food => QuickActionColors.food,
    grocery => QuickActionColors.groceries,
    errands => QuickActionColors.errands,
  };
}
