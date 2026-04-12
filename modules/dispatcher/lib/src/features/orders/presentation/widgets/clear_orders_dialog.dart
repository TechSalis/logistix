import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

class ClearOrdersDialog {
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onClear,
  }) {
    return BootstrapDialog.show<void>(
      context: context,
      title: 'Clear all orders?',
      content: 'This will remove all orders you have prepared.',
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
