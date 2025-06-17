import 'package:flutter/material.dart';

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
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Theme.of(context).bottomSheetTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: Theme.of(context).bottomSheetTheme.elevation!,
            color: Theme.of(context).bottomSheetTheme.shadowColor!,
          ),
        ],
      ),
      child: Column(children: [SizedBox(height: 24), Flexible(child: child)]),
    );
  }
}
