import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:shared/src/core/services/toast/widgets/app_toast.dart';

/// Implementation of IToastService using overlay-based toasts
class ToastServiceImpl implements IToastService {
  ToastServiceImpl(this._overlayState);

  final OverlayState _overlayState;
  OverlayEntry? _currentOverlayEntry;

  @override
  void showCustomToast(Widget toast) {
    dismiss();
    _currentOverlayEntry = OverlayEntry(builder: (_) => toast);
    _overlayState.insert(_currentOverlayEntry!);
  }

  @override
  void showToast(
    String message, {
    required ToastType type,
    Duration? duration,
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    dismiss();
    _currentOverlayEntry = OverlayEntry(
      builder: (context) => AppToast(
        message: message,
        type: type,
        duration: duration ?? const Duration(seconds: 4),
        onDismiss: dismiss,
        onTap: onTap,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
    _overlayState.insert(_currentOverlayEntry!);
  }

  @override
  void dismiss() {
    _currentOverlayEntry?.remove();
    _currentOverlayEntry = null;
  }
}
