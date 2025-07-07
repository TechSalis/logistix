import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
            color: Theme.of(context).progressIndicatorTheme.color,
          ),
          const SizedBox(height: 32),
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
