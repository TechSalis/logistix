import 'package:flutter/material.dart';
import 'package:logistix_ux/logistix_ux.dart';

/// A centered loading indicator with optional message
/// Use this instead of Center(child: CircularProgressIndicator())
class LogistixLoadingIndicator extends StatelessWidget {
  const LogistixLoadingIndicator({this.message, this.size = 40.0, super.key});

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(LogistixColors.primary),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: LogistixSpacing.md),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: LogistixColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A small inline loading indicator for buttons and compact spaces
class LogistixInlineLoader extends StatelessWidget {
  const LogistixInlineLoader({this.size = 20.0, this.color, super.key});

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? LogistixColors.primary,
        ),
      ),
    );
  }
}
