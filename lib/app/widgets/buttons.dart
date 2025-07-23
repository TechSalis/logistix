import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({super.key, required this.child, this.onPressed});

  final Widget child;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: DefaultTextStyle(
        style: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
        child: child,
      ),
    );
  }
}

class ElevatedLoadingButton extends StatefulWidget {
  const ElevatedLoadingButton({
    super.key,
    this.onPressed,
    required this.controller,
    required this.child,
    this.resetAfterDuration,
  });

  ElevatedLoadingButton.icon({
    super.key,
    this.onPressed,
    required this.controller,
    required Widget icon,
    required Widget label,
    this.resetAfterDuration,
  }) : child = Row(
         mainAxisSize: MainAxisSize.min,
         children: [icon, const SizedBox(width: 8), label],
       );

  final Widget child;
  final RoundedLoadingButtonController controller;
  final Duration? resetAfterDuration;
  final void Function()? onPressed;

  @override
  State<ElevatedLoadingButton> createState() => _ElevatedLoadingButtonState();
}

class _ElevatedLoadingButtonState extends State<ElevatedLoadingButton> {
  StreamSubscription? _sub;

  @override
  void initState() {
    if (widget.resetAfterDuration != null) {
      _sub = widget.controller.stateStream.listen((event) {
        if (event == ButtonState.error || event == ButtonState.success) {
          Future.delayed(widget.resetAfterDuration!, () {
            if (mounted) widget.controller.reset();
          });
        }
      });
    }
    super.initState();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, consts) {
        return RoundedLoadingButton(
          height: 46,
          width: consts.maxWidth,
          borderRadius: 8,
          animateOnTap: false,
          resetDuration: Durations.extralong4,
          color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor
              ?.resolve({WidgetState.selected}),
          controller: widget.controller,
          onPressed: widget.onPressed,
          child: widget.child,
        );
      },
    );
  }
}
