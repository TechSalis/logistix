import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';

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
  const ElevatedLoadingButton.icon({
    super.key,
    this.onPressed,
    required this.button,
    this.resetAfterDuration,
    this.state,
  });

  final ValueNotifier<ButtonState>? state;
  final IconedButton button;
  final Duration? resetAfterDuration;
  final void Function()? onPressed;

  @override
  State<ElevatedLoadingButton> createState() => _ElevatedLoadingButtonState();
}

class _ElevatedLoadingButtonState extends State<ElevatedLoadingButton> {
  @override
  void initState() {
    if (widget.resetAfterDuration != null) {
      widget.state?.addListener(() {
        if (widget.state!.value == ButtonState.fail ||
            widget.state!.value == ButtonState.success) {
          Future.delayed(widget.resetAfterDuration!, () {
            if (mounted) setState(() => widget.state!.value = ButtonState.idle);
          });
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProgressButton.icon(
      onPressed: widget.onPressed,
      iconedButtons: {
        ButtonState.idle: widget.button,
        ButtonState.loading: IconedButton(color: widget.button.color),
        ButtonState.fail: IconedButton(
          // text: "Failed",
          icon: const Icon(Icons.cancel, color: Colors.white),
          color: Theme.of(context).colorScheme.error,
        ),
        ButtonState.success: IconedButton(
          // text: "Success",
          icon: const Icon(Icons.check_circle, color: Colors.white),
          color: Colors.green.shade400,
        ),
      },
      height: 46.0,
      radius: buttonRadius.x,
      textStyle: Theme.of(
        context,
      ).elevatedButtonTheme.style!.textStyle?.resolve({WidgetState.selected}),
      state: widget.state?.value ?? ButtonState.idle,
      minWidthStates: const [
        ButtonState.loading,
        ButtonState.fail,
        ButtonState.success,
      ],
    );
  }
}
