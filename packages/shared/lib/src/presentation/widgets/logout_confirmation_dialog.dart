import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

class LogoutConfirmationDialog {
  static Future<void> show(
    BuildContext context, {
    required VoidCallback onLogout,
  }) {
    return BootstrapDialog.show<void>(
      context: context,
      title: 'Logout',
      content: 'Are you sure you want to sign out?',
      icon: Icons.logout_rounded,
      type: BootstrapDialogType.destructive,
      primaryActionText: 'Logout',
      secondaryActionText: 'Cancel',
      onPrimaryAction: (dialogContext) {
        Navigator.pop(dialogContext);
        onLogout();
      },
    );
  }
}
