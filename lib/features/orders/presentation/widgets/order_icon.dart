import 'package:flutter/material.dart';
import 'package:logistix/app/presentation/widgets/avatar_icon.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';

class OrderIcon extends StatelessWidget {
  const OrderIcon({super.key, required this.type, this.size, this.color});
  final OrderType type;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: AvatarIcon(
        backgroundColor: (color ?? type.color).withAlpha(30),
        icon: Icon(
          type.icon,
          color: color ?? type.color,
          size: size != null ? (size! * .5) : null,
        ),
      ),
    );
  }
}
