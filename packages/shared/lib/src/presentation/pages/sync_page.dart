import 'package:bootstrap/definitions/app_error.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:shared/src/core/config/env_config.dart';

/// A centralized, "dumb" page for performing critical asynchronous operations.
///
/// This component focuses purely on the visual state (loading animation, message)
/// and delegates process control and error handling to the caller.
class SyncPage extends StatefulWidget {
  const SyncPage({
    required this.onInitialize,
    this.onSuccess,
    this.onError,
    this.message,
    super.key,
  });

  /// The async logic to perform.
  final Future<void> Function() onInitialize;

  /// Optional callback on success. Use if the parent doesn't handle completion via futures.
  final VoidCallback? onSuccess;

  /// Optional callback on error. Use to show custom popups or handle failures.
  final void Function(BuildContext context, Object error, VoidCallback onRetry)?
  onError;

  /// Stylized message for the loading state.
  final String? message;

  /// Helper to create a [CustomTransitionPage] for this page.
  static Page<void> page({
    required Future<void> Function() onInitialize,
    required GoRouterState state,
    VoidCallback? onSuccess,
    void Function(BuildContext context, Object error, VoidCallback onRetry)?
    onError,
    String? message,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      transitionDuration: const Duration(milliseconds: 600),
      reverseTransitionDuration: const Duration(milliseconds: 600),
      child: SyncPage(
        onInitialize: onInitialize,
        onSuccess: onSuccess,
        onError: onError,
        message: message,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: child,
          ),
        );
      },
    );
  }

  /// Helper to show the standard sync error dialog.
  static void showErrorDialog(
    BuildContext context, {
    required Object error,
    required VoidCallback onRetry,
    required VoidCallback onLogout,
  }) {
    final message =
        (error is UserError ? error.message : null) ??
        'Failed to synchronize data. Please check your internet connection.';

    BootstrapDialog.show<void>(
      context: context,
      barrierDismissible: false,
      title: 'Sync Error',
      content: message,
      actionsBuilder: (dialogContext) => [
        BootstrapButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            onRetry();
          },
          label: 'Retry',
          icon: Icons.refresh,
        ),
        const SizedBox(height: 12),
        BootstrapButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            onLogout();
          },
          label: 'Logout',
          icon: Icons.logout,
          type: BootstrapButtonType.text,
        ),
      ],
    );
  }

  @override
  State<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends State<SyncPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startProcess();
  }

  void _initAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
  }

  Future<void> _startProcess() async {
    if (_isProcessing) return;
    if (mounted) setState(() => _isProcessing = true);

    try {
      await widget.onInitialize();
      if (mounted) widget.onSuccess?.call();
    } catch (e) {
      if (mounted) {
        if (widget.onError != null) {
          widget.onError!(context, e, _startProcess);
        } else {
          // Fallback if no error handler provided
          rethrow;
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Hero(
          tag: 'sync_page',
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LogistixAssets.images.icon.image(height: 120, width: 120),
                const SizedBox(height: 24),
                Text(
                  EnvConfig.instance.appName,
                  style: context.textTheme.headlineLarge?.bold.copyWith(
                    letterSpacing: 1.2,
                  ),
                ),
                if (widget.message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.message!,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
                const SizedBox(height: 48),
                const SizedBox.square(
                  dimension: 40,
                  child: BootstrapLoadingIndicator(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
