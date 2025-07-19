import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LargeLoadingIndicator extends StatelessWidget {
  const LargeLoadingIndicator({super.key, this.size = 24});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(
      color: Theme.of(context).colorScheme.primary,
      size: size,
    );
  }
}
