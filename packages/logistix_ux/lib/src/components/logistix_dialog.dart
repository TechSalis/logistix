import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

class LogistixDialog extends StatelessWidget {
  const LogistixDialog({
    required this.title,
    required this.content,
    this.primaryActionText,
    this.onPrimaryAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.actions,
    this.icon,
    this.iconColor,
    this.isDestructive = false,
    super.key,
  });

  final String title;
  final String content;
  final String? primaryActionText;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;
  final List<Widget>? actions;
  final IconData? icon;
  final Color? iconColor;
  final bool isDestructive;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String content,
    String? primaryActionText,
    VoidCallback? onPrimaryAction,
    String? secondaryActionText,
    VoidCallback? onSecondaryAction,
    List<Widget>? actions,
    IconData? icon,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'LogistixDialog',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return LogistixDialog(
          title: title,
          content: content,
          primaryActionText: primaryActionText,
          onPrimaryAction: onPrimaryAction,
          secondaryActionText: secondaryActionText,
          onSecondaryAction: onSecondaryAction,
          actions: actions,
          icon: icon,
          iconColor: iconColor,
          isDestructive: isDestructive,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 8 * animation.value,
            sigmaY: 8 * animation.value,
          ),
          child: FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor =
        iconColor ??
        (isDestructive ? LogistixColors.error : LogistixColors.primary);
    final primaryButtonColor = isDestructive
        ? LogistixColors.error
        : LogistixColors.primary;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  children: [
                    if (icon != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: effectiveIconColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, size: 32, color: effectiveIconColor),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      title,
                      style: context.textTheme.headlineSmall?.bold.copyWith(
                        color: LogistixColors.neutral800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: LogistixColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (actions != null)
                      ...actions!.map(
                        (a) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: a,
                        ),
                      )
                    else ...[
                      if (primaryActionText != null && onPrimaryAction != null)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryButtonColor,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: onPrimaryAction,
                          child: Text(
                            primaryActionText!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (secondaryActionText != null) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: LogistixColors.textSecondary,
                          ),
                          onPressed:
                              onSecondaryAction ??
                              () => Navigator.of(context).pop(),
                          child: Text(secondaryActionText!),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
