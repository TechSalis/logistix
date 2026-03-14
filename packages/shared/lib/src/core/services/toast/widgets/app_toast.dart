import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

/// Generic toast widget that displays messages with different styles
class AppToast extends StatefulWidget {
  const AppToast({
    required this.message,
    required this.type,
    required this.onDismiss,
    this.duration,
    this.onTap,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final ToastType type;
  final Duration? duration;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  State<AppToast> createState() => _AppToastState();
}

class _AppToastState extends State<AppToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Start animation
    _controller.forward();

    // Auto-dismiss after duration
    if (widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (mounted) _dismiss();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            elevation: 4,
            shadowColor: Colors.black45,
            borderRadius: BorderRadius.circular(12),
            child: ToastContent(
              message: widget.message,
              type: widget.type,
              onDismiss: _dismiss,
              onTap: widget.onTap,
              actionLabel: widget.actionLabel,
              onAction: widget.onAction,
            ),
          ),
        ),
      ),
    );
  }
}

/// Content widget for the toast
class ToastContent extends StatelessWidget {
  const ToastContent({
    required this.message,
    required this.type,
    required this.onDismiss,
    this.onTap,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String message;
  final ToastType type;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getToastConfig(type, theme);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: config.borderColor),
        ),
        child: Row(
          children: [
            Icon(config.icon, color: config.iconColor, size: 20),

            const SizedBox(width: 12),

            // Message
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.medium.copyWith(
                  color: config.textColor,
                ),
              ),
            ),

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  onAction?.call();
                  onDismiss();
                },
                style: TextButton.styleFrom(
                  foregroundColor: config.iconColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  actionLabel!,
                  style: context.textTheme.labelLarge?.semiBold,
                ),
              ),
            ],

            // Close button (only if no loading)
            const SizedBox(width: 8),
            InkWell(
              onTap: onDismiss,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: config.iconColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ToastConfig _getToastConfig(ToastType type, ThemeData theme) {
    switch (type) {
      case ToastType.success:
        return _ToastConfig(
          icon: Icons.check_circle,
          iconColor: Colors.green.shade700,
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          textColor: Colors.green.shade900,
        );
      case ToastType.error:
        return _ToastConfig(
          icon: Icons.error,
          iconColor: Colors.red.shade700,
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
          textColor: Colors.red.shade900,
        );
      case ToastType.warning:
        return _ToastConfig(
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange.shade700,
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          textColor: Colors.orange.shade900,
        );
      case ToastType.info:
        return _ToastConfig(
          icon: Icons.info,
          iconColor: Colors.blue.shade700,
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          textColor: Colors.blue.shade900,
        );
    }
  }
}

class _ToastConfig {
  const _ToastConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
}
