import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ElevatedLoadingButton extends StatelessWidget {
  const ElevatedLoadingButton({
    super.key,
    this.onPressed,
    required this.controller,
    required this.child,
  });

  ElevatedLoadingButton.icon({
    super.key,
    this.onPressed,
    required this.controller,
    required Widget icon,
    required Widget label,
  }) : child = Row(
         mainAxisSize: MainAxisSize.min,
         children: [icon, const SizedBox(width: 8), label],
       );

  final Widget child;
  final RoundedLoadingButtonController controller;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, consts) {
        return RoundedLoadingButton(
          height: 42,
          width: consts.maxWidth,
          borderRadius: 8,
          animateOnTap: false,
          onPressed: onPressed,
          controller: controller,
          color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor
              ?.resolve({WidgetState.selected}),
          child: child,
        );
      },
    );
  }
}
