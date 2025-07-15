import 'dart:math';

import 'package:flutter/material.dart';

class PanAwayListener extends StatefulWidget {
  const PanAwayListener({
    super.key,
    required this.child,
    required this.onPanAway,
    this.panAwayOffset = 50,
    this.enabled = true,
  });

  final bool enabled;
  final double panAwayOffset;
  final Widget child;
  final void Function(bool followMarker) onPanAway;

  @override
  State<PanAwayListener> createState() => _PanAwayListenerState();
}

class _PanAwayListenerState extends State<PanAwayListener> {
  /// True - centered. False - Panned away. Null -
  bool isCenteredState = true;
  Offset? tapDownPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        if (!widget.enabled) return;
        tapDownPosition = event.position;
        // Dont update UI yet to show track location hutton
        isCenteredState = false;
      },
      onPointerUp: (event) {
        if (!widget.enabled) return;
        // if (followMarkerState) return;
        final dx = (tapDownPosition!.dx - event.position.dx).abs();
        final dy = (tapDownPosition!.dy - event.position.dy).abs();

        //Now we can update UI to show track location hutton
        if (max(dx, dy) < widget.panAwayOffset) {
          isCenteredState = true;
        }
        widget.onPanAway(isCenteredState != true);
      },
      child: widget.child,
    );
  }
}
