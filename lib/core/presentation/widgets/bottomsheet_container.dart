import 'package:flutter/material.dart';
import 'package:logistix/core/presentation/theme/styling.dart';

class BottomsheetContainer extends StatelessWidget {
  const BottomsheetContainer({
    super.key,
    required this.child,
    this.borderRadius = borderRadius_32,
  });

  final BorderRadiusGeometry borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: context.boxDecorationWithShadow.copyWith(
        borderRadius: borderRadius,
      ),
      child: Column(
        children: [const SizedBox(height: 20), Flexible(child: child)],
      ),
    );
  }
}
