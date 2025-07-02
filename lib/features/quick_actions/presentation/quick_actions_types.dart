import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logistix/core/constants/colors.dart';

interface class QuickActionType extends Equatable {
  final String label;
  final IconData icon;
  final Color color;

  const QuickActionType._({
    required this.label,
    required this.icon,
    required this.color,
  });

  static const food = QuickActionType._(
    label: 'Food',
    color: QuickActionColors.food,
    icon: Icons.lunch_dining,
  );
  // static const repeatOrder = QuickActionType._(
  //   label: 'Last Order',
  //   color: QuickActionColors.lastDelivery,
  //   icon: Icons.repeat,
  // );
  static const delivery = QuickActionType._(
    label: 'Delivery',
    color: AppColors.blueGreyMaterial,
    icon: Icons.moped,
  );
  static const groceries = QuickActionType._(
    label: 'Groceries',
    color: QuickActionColors.groceries,
    icon: Icons.shopping_cart,
  );
  static const errands = QuickActionType._(
    label: 'Errands',
    color: QuickActionColors.errands,
    icon: Icons.list_alt,
  );

  static const values = [food, groceries, errands, delivery];

  @override
  List<Object?> get props => [label, color, icon];
}

// interface class QuickActionType extends Equatable {
//   final String label;
//   final IconData icon;
//   final Color color;

//   const QuickActionType._({
//     required this.label,
//     required this.icon,
//     required this.color,
//   });

//   static const delivery = QuickActionType._(
//     label: 'Delivery',
//     color: AppColors.blueGreyMaterial,
//     icon: Icons.motorcycle,
//   );

//   @override
//   List<Object?> get props => [label, color, icon];
// }
