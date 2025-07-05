import 'package:flutter/material.dart';
import 'package:logistix/features/notifications/presentation/widgets/notification_profile_icon.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';

class OrderIcon extends StatelessWidget {
  const OrderIcon({super.key, required this.action, this.size, this.color});
  final OrderType action;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: AvatarIcon(
        backgroundColor: (color ?? action.color).withAlpha(20),
        icon: Icon(
          action.icon,
          color: color ?? action.color,
          size: size != null ? (size! * .5) : null,
        ),
      ),
    );
  }
}
