import 'package:bootstrap/extensions/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

extension RiderStatusStyling on RiderStatus {
  Color get color {
    switch (this) {
      case RiderStatus.online:
        return LogistixColors.success;
      case RiderStatus.busy:
        return LogistixColors.warning;
      case RiderStatus.offline:
        return LogistixColors.textTertiary;
    }
  }

  String get label => value.capitalizeFirst();
}

extension OrderStatusStyling on OrderStatus {
  Color get color {
    switch (this) {
      case OrderStatus.UNASSIGNED:
        return LogistixColors.textTertiary;
      case OrderStatus.ASSIGNED:
        return LogistixColors.info;
      case OrderStatus.EN_ROUTE:
        return LogistixColors.warning;
      case OrderStatus.DELIVERED:
        return LogistixColors.success;
      case OrderStatus.CANCELLED:
        return LogistixColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.UNASSIGNED:
        return Icons.timer_outlined;
      case OrderStatus.ASSIGNED:
        return Icons.person_add_outlined;
      case OrderStatus.EN_ROUTE:
        return Icons.local_shipping_outlined;
      case OrderStatus.DELIVERED:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.CANCELLED:
        return Icons.cancel_outlined;
    }
  }

  String get description {
    switch (this) {
      case OrderStatus.UNASSIGNED:
        return 'Waiting for a rider to be assigned';
      case OrderStatus.ASSIGNED:
        return 'A rider has been assigned and will pick up shortly';
      case OrderStatus.EN_ROUTE:
        return 'Rider is on the way to the delivery location';
      case OrderStatus.DELIVERED:
        return 'Order has been successfully delivered';
      case OrderStatus.CANCELLED:
        return 'This order has been cancelled';
    }
  }
}
