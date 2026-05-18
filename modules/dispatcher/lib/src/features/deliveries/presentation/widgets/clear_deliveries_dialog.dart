import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

class ClearDeliveriesDialog {
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onClear,
  }) {
    return BootstrapDialog.show<void>(
      context: context,
      title: 'Clear all deliveries?',
      content: 'This will remove all deliveries you have prepared.',
      primaryActionText: 'Clear All',
      type: BootstrapDialogType.destructive,
      onPrimaryAction: (dialogContext) {
        onClear();
        Navigator.pop(dialogContext);
      },
      secondaryActionText: 'Cancel',
    );
  }
}
