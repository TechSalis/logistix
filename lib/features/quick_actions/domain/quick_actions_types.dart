import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:logistix/core/constants/colors.dart';

interface class QuickActionType extends ActionType {
  const QuickActionType._({
    required super.label,
    required super.icon,
    required super.color,
  }) : super._();

  static const food = QuickActionType._(
    label: 'Food',
    color: QuickActionColors.food,
    icon: Icons.lunch_dining,
  );
  static const repeatOrder = QuickActionType._(
    label: 'Last Order',
    color: QuickActionColors.lastDelivery,
    icon: Icons.repeat,
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

  static const values = [food, groceries, errands, repeatOrder];
}

interface class ActionType extends Equatable {
  final String label;
  final IconData icon;
  final Color color;

  const ActionType._({
    required this.label,
    required this.icon,
    required this.color,
  });

  static const delivery = ActionType._(
    label: 'Delivery',
    color: AppColors.blueGreyMaterial,
    icon: Icons.motorcycle,
  );

  @override
  List<Object?> get props => [label, color, icon];
}
