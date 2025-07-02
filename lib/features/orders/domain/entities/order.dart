// lib/features/orders/domain/entities/order.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logistix/core/constants/colors.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/quick_actions/presentation/quick_actions_types.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';

class Order extends Equatable {
  final String id;
  final Address pickUp;
  final Address dropOff;
  final double price;
  final QuickActionType type;
  final OrderStatus status;
  final String? description;
  final Rider? rider;

  const Order({
    required this.id,
    required this.type,
    required this.pickUp,
    required this.dropOff,
    required this.price,
    required this.status,
    this.description,
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

enum OrderStatus {
  pending,
  confirmed,
  enRoute,
  delivered,
  cancelled;

  String get label => switch (this) {
    OrderStatus.pending => 'Pending',
    OrderStatus.confirmed => 'Confirmed',
    OrderStatus.enRoute => 'On the way',
    OrderStatus.delivered => 'Delivered',
    OrderStatus.cancelled => 'Cancelled',
  };

  Color get color => switch (this) {
    OrderStatus.pending => Colors.grey.shade500,
    OrderStatus.confirmed => AppColors.orange.withAlpha(200),
    OrderStatus.enRoute => AppColors.orange,
    OrderStatus.delivered => Colors.green,
    OrderStatus.cancelled => Colors.red,
  };
}
