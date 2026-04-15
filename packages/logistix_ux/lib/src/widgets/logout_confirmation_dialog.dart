import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

class LogoutConfirmationDialog extends StatefulWidget {
  const LogoutConfirmationDialog({required this.onLogout, super.key});

  final AsyncCallback onLogout;

  static Future<void> show(
    BuildContext context, {
    required AsyncCallback onLogout,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LogoutConfirmationDialog(onLogout: onLogout),
    );
  }

  @override
  State<LogoutConfirmationDialog> createState() =>
      _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    await widget.onLogout.call();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BootstrapRadii.lg),
      ),
      title: const Row(
        children: [
          Icon(Icons.logout_rounded, color: LogistixColors.error, size: 24),
          SizedBox(width: 12),
          Text('Logout'),
        ],
      ),
      content: const Text('Are you sure you want to sign out?'),
      actions: [
        BootstrapButton(
          isLoading: _isLoading,
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        BootstrapButton(
          isLoading: _isLoading,
          onPressed: _handleLogout,
          label: 'Logout',
          backgroundColor: LogistixColors.error,
          foregroundColor: LogistixColors.white,
        ),
      ],
    );
  }
}
