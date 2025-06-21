import 'package:flutter/material.dart';
import 'package:logistix/core/constants/colors.dart';

interface class QuickAction {
  final String name;
  final IconData icon;
  final Color color;

  const QuickAction._({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const food = QuickAction._(
    name: 'Food',
    color: QuickActionColors.food,
    icon: Icons.lunch_dining,
  );
  static const repeatOrder = QuickAction._(
    name: 'Last Order',
    color: QuickActionColors.lastDelivery,
    icon: Icons.repeat,
  );
  static const groceries = QuickAction._(
    name: 'Groceries',
    color: QuickActionColors.groceries,
    icon: Icons.shopping_cart,
  );
  static const errands = QuickAction._(
    name: 'Errands',
    color: QuickActionColors.errands,
    icon: Icons.list_alt,
  );
}
