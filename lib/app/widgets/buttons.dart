import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logistix/core/theme/styling.dart';
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
  const ElevatedLoadingButton({
    super.key,
    this.onPressed,
    required this.child,
    required this.state,
    this.resetAfterDuration,
  });

  ElevatedLoadingButton.icon({
    super.key,
    this.onPressed,
    required Widget label,
    required Widget icon,
    required this.state,
    this.resetAfterDuration,
  }) : child = _Button(icon: icon, label: label);

  final ValueNotifier<ButtonState> state;
  final Widget child;
  final Duration? resetAfterDuration;
  final void Function()? onPressed;

  @override
  State<ElevatedLoadingButton> createState() => _ElevatedLoadingButtonState();
}

class _ElevatedLoadingButtonState extends State<ElevatedLoadingButton> {
  @override
  void initState() {
    if (widget.resetAfterDuration != null) {
      widget.state.addListener(() {
        if (widget.state.value == ButtonState.fail ||
            widget.state.value == ButtonState.success) {
          Future.delayed(widget.resetAfterDuration!, () {
            if (mounted) widget.state.value = ButtonState.idle;
          });
        }
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final idleColor =
        Theme.of(context).elevatedButtonTheme.style!.backgroundColor!.resolve({
          WidgetState.selected,
        })!;
    return ValueListenableBuilder(
      valueListenable: widget.state,
      builder: (context, value, child) {
        return ProgressButton(
          onPressed: widget.onPressed,
          state: value,
          buttonStyle:
              value == ButtonState.loading
                  ? ElevatedButton.styleFrom(padding: padding_8)
                  : null,
          stateWidgets: {
            ButtonState.idle: widget.child,
            ButtonState.loading: const SizedBox.square(
              dimension: 28,
              child: CircularProgressIndicator(
                padding: EdgeInsets.zero,
                backgroundColor: Colors.white,
              ),
            ),
            ButtonState.fail: const _Button(
              icon: Icon(Icons.cancel),
              label: Text("Failed"),
            ),
            ButtonState.success: const _Button(
              icon: Icon(Icons.check),
              label: Text("Success"),
            ),
          },
          stateColors: {
            ButtonState.idle: idleColor,
            ButtonState.loading: idleColor,
            ButtonState.fail: Theme.of(context).colorScheme.error,
            ButtonState.success: Colors.green,
          },
        );
      },
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.icon, required this.label});
  final Widget icon;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [icon, const SizedBox(width: 8), label],
    );
  }
}
