import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

enum LogistixDialogType { info, success, warning, error, destructive }

class LogistixDialog extends StatelessWidget {
  const LogistixDialog({
    required this.title,
    required this.content,
    this.type = LogistixDialogType.info,
    this.icon,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.primaryActionText,
    this.secondaryActionText,
    this.actionsBuilder,
    this.isDestructive = false,
    this.iconColor,
    super.key,
  });

  final String title;
  final String content;
  final LogistixDialogType type;
  final IconData? icon;
  final String? primaryActionText;
  final String? secondaryActionText;
  final void Function(BuildContext context)? onPrimaryAction;
  final void Function(BuildContext context)? onSecondaryAction;
  final List<Widget> Function(BuildContext context)? actionsBuilder;
  final bool isDestructive;
  final Color? iconColor;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required String content,
    LogistixDialogType type = LogistixDialogType.info,
    IconData? icon,
    String? primaryActionText,
    String? secondaryActionText,
    void Function(BuildContext context)? onPrimaryAction,
    void Function(BuildContext context)? onSecondaryAction,
    List<Widget> Function(BuildContext context)? actionsBuilder,
    Color? iconColor,
    bool barrierDismissible = true,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'LogistixDialog',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, _, __) => LogistixDialog(
        title: title,
        content: content,
        type: type,
        icon: icon,
        primaryActionText: primaryActionText,
        secondaryActionText: secondaryActionText,
        onPrimaryAction: onPrimaryAction,
        onSecondaryAction: onSecondaryAction,
        actionsBuilder: actionsBuilder,
        iconColor: iconColor,
      ),
      transitionBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
      ) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5 * animation.value,
            sigmaY: 5 * animation.value,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: FadeTransition(opacity: animation, child: child),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveType = isDestructive ? LogistixDialogType.destructive : type;

    final color = iconColor ??
        switch (effectiveType) {
          LogistixDialogType.success => LogistixColors.success,
          LogistixDialogType.warning => LogistixColors.warning,
          LogistixDialogType.error ||
          LogistixDialogType.destructive =>
            LogistixColors.error,
          _ => LogistixColors.primary,
        };

    final effectiveIcon = icon ??
        switch (effectiveType) {
          LogistixDialogType.success => Icons.check_circle_rounded,
          LogistixDialogType.warning => Icons.warning_rounded,
          LogistixDialogType.error ||
          LogistixDialogType.destructive =>
            Icons.error_rounded,
          _ => Icons.info_rounded,
        };

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(effectiveIcon, color: color, size: 32),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleLarge?.bold,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: LogistixColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (actionsBuilder != null)
                    ...actionsBuilder!(context)
                  else ...[
                    LogistixButton(
                      onPressed: onPrimaryAction != null
                          ? () => onPrimaryAction!(context)
                          : () => Navigator.pop(context),
                      label: primaryActionText ?? 'OK',
                      backgroundColor: color,
                    ),
                    if (secondaryActionText != null) ...[
                      const SizedBox(height: 12),
                      LogistixButton(
                        onPressed: onSecondaryAction != null
                            ? () => onSecondaryAction!(context)
                            : () => Navigator.pop(context),
                        label: secondaryActionText!,
                        type: LogistixButtonType.text,
                      ),
                    ],
                  ],
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.close_rounded,
                  color: LogistixColors.textTertiary,
                  size: 24,
                ),
                visualDensity: VisualDensity.compact,
                splashRadius: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
