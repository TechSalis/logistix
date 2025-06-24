import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AsyncStatusView<T> extends StatefulWidget {
  const AsyncStatusView({
    super.key,
    required this.computation,
    this.successMessage = "Success!",
    this.loadingMessage = "Submitting...",
    this.errorMessage = "Something went wrong.",
    this.onRetry,
  });

  final String successMessage;
  final String loadingMessage;
  final String errorMessage;
  final Future<T> Function() computation;
  final Future<T> Function()? onRetry;

  @override
  State<AsyncStatusView<T>> createState() => _AsyncStatusViewState<T>();
}

class _AsyncStatusViewState<T> extends State<AsyncStatusView<T>> {
  Future<T>? future;

  @override
  void initState() {
    future = widget.computation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        Widget child;
        if (snapshot.hasError) {
          child = _ErrorState(
            message: widget.errorMessage,
            onRetry:
                widget.onRetry == null
                    ? null
                    : () => setState(() => future = widget.onRetry!()),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          child = _SuccessState(message: widget.successMessage);
        } else {
          child = LoadingStatusView(message: widget.loadingMessage);
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeInOut,
          child: child,
        );
      },
    );
  }
}

class LoadingStatusView extends StatelessWidget {
  const LoadingStatusView({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('loading'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitRipple(
            size: 100,
            // duration: Duration(milliseconds: 1500),
            color: Theme.of(context).progressIndicatorTheme.color,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  const _SuccessState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('success'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Colors.green,
            size: 100,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('error'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 100),
          const SizedBox(height: 24),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ],
      ),
    );
  }
}
