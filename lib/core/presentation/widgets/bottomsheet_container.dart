import 'package:flutter/material.dart';
import 'package:logistix/core/constants/styling.dart';

class BottomsheetContainer extends StatelessWidget {
  const BottomsheetContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(32)),
  });

  final BorderRadiusGeometry borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: context.boxDecorationWithShadow.copyWith(
        borderRadius: borderRadius,
      ),
      child: Column(children: [SizedBox(height: 20), Flexible(child: child)]),
    );
  }
}
