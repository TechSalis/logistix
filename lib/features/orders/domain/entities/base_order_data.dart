import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logistix/core/theme/colors.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';


/// In sync with data values in the backend
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
    food => Icons.fastfood,
    grocery => Icons.shopping_cart,
    errands => Icons.local_mall,
  };

  Color get color => switch (this) {
    delivery => QuickActionColors.delivery,
    food => QuickActionColors.food,
    grocery => QuickActionColors.groceries,
    errands => QuickActionColors.errands,
  };
}

abstract base class BaseOrderData extends Equatable {
  final Address? pickup, dropoff;
  final double? price;
  final OrderType orderType;
  final String description;

  const BaseOrderData({
    required this.pickup,
    required this.dropoff,
    this.price,
    required this.orderType,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'pickup': pickup?.toJson(),
    'dropoff': dropoff?.toJson(),
    'price': price,
    'order_type': orderType.name,
    'description': description,
  };
  
  @override
  List<Object?> get props => [description, pickup, dropoff, orderType, price];

}
