import 'package:flutter/material.dart';

class MapPanUnfocusListener extends StatefulWidget {
  const MapPanUnfocusListener({
    super.key,
    required this.child,
    required this.shouldFollowMarker,
  });

  final Widget child;
  final void Function(bool followMarker) shouldFollowMarker;

  @override
  State<MapPanUnfocusListener> createState() => _MapPanUnfocusListenerState();
}

class _MapPanUnfocusListenerState extends State<MapPanUnfocusListener> {
  bool? followMarkerState = true;
  Offset? tapDownPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) {
        tapDownPosition = event.position;
        //Dont update UI yet to show track location hutton
        if (followMarkerState == true) {
          followMarkerState = false;
        } else {
          followMarkerState = null;
        }
      },
      onPointerUp: (event) {
        // if (followMarkerState) return;
        final dx = (tapDownPosition!.dx - event.position.dx).abs();
        final dy = (tapDownPosition!.dy - event.position.dy).abs();

        //Now we can update UI to show track location hutton
        if ((dx < 40 || dy < 40) && followMarkerState == false) {
          followMarkerState = true;
        }
        widget.shouldFollowMarker(followMarkerState == true);
      },
      child: widget.child,
    );
  }
}
