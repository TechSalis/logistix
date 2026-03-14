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
      case OrderStatus.unassigned:
        return LogistixColors.textTertiary;
      case OrderStatus.assigned:
        return LogistixColors.info;
      case OrderStatus.enRoute:
        return LogistixColors.warning;
      case OrderStatus.delivered:
        return LogistixColors.success;
      case OrderStatus.cancelled:
        return LogistixColors.error;
    }
  }

}
