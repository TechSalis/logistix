import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/shared.dart';

extension RiderStatusStyling on RiderStatus {
  Color get color {
    switch (this) {
      case RiderStatus.ONLINE:
        return LogistixColors.success;
      case RiderStatus.BUSY:
        return LogistixColors.warning;
      case RiderStatus.OFFLINE:
        return LogistixColors.textTertiary;
    }
  }
}

extension DeliveryStatusStyling on DeliveryStatus {
  Color get color {
    switch (this) {
      case DeliveryStatus.PENDING:
        return LogistixColors.textTertiary;
      case DeliveryStatus.ASSIGNED:
        return LogistixColors.info;
      case DeliveryStatus.EN_ROUTE:
        return LogistixColors.warning;
      case DeliveryStatus.DELIVERED:
        return LogistixColors.success;
      case DeliveryStatus.CANCELLED:
        return LogistixColors.error;
    }
  }

  IconData get icon {
    switch (this) {
      case DeliveryStatus.PENDING:
        return Icons.timer_outlined;
      case DeliveryStatus.ASSIGNED:
        return Icons.person_add_outlined;
      case DeliveryStatus.EN_ROUTE:
        return Icons.local_shipping_outlined;
      case DeliveryStatus.DELIVERED:
        return Icons.check_circle_outline_rounded;
      case DeliveryStatus.CANCELLED:
        return Icons.cancel_outlined;
    }
  }

  String get description {
    switch (this) {
      case DeliveryStatus.PENDING:
        return 'Waiting for a rider to be assigned';
      case DeliveryStatus.ASSIGNED:
        return 'A rider has been assigned and will begin shortly';
      case DeliveryStatus.EN_ROUTE:
        return 'Rider is on the way to the delivery location';
      case DeliveryStatus.DELIVERED:
        return 'Delivery has been successfully delivered';
      case DeliveryStatus.CANCELLED:
        return 'This delivery has been cancelled';
    }
  }
}
