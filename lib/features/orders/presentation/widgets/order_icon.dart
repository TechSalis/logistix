import 'package:flutter/material.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/features/orders/domain/entities/base_order_data.dart';

class OrderIcon extends StatelessWidget {
  const OrderIcon({super.key, required this.type, this.size, this.color});
  final OrderType type;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: (color ?? type.color).withAlpha(30),
          border: Border.all(color: (color ?? type.color).withAlpha(60)),
          borderRadius: borderRadius_16,
        ),
        child: Icon(
          type.icon,
          color: color ?? type.color,
          size: size != null ? (size! * .5) : null,
        ),
      ),
    );
  }
}
