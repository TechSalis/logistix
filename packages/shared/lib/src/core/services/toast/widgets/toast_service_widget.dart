import 'package:bootstrap/interfaces/toast/toast_service.dart';
import 'package:bootstrap/interfaces/toast/toast_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:shared/src/core/services/toast/toast_service_impl.dart';

/// Wrapper widget that provides ToastService to the app
/// This widget must be placed inside a Navigator/MaterialApp that has an Overlay
class ToastServiceWidget extends StatefulWidget {
  const ToastServiceWidget({required this.child, super.key});
  final Widget child;

  @override
  State<ToastServiceWidget> createState() => _ToastServiceWidgetState();
}

class _ToastServiceWidgetState extends State<ToastServiceWidget> {
  late final IToastService _toastService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize toast service with the router's overlay
    // This allows the child to navigate normally while toasts use the overlay
    _toastService = ToastServiceImpl(Overlay.of(context));
  }

  @override
  Widget build(BuildContext context) {
    return ToastServiceProvider(service: _toastService, child: widget.child);
  }
}
