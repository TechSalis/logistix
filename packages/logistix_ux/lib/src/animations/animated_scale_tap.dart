import 'package:flutter/material.dart';
import 'package:logistix_ux/src/animations/animation_constants.dart';

/// A widget that scales down on tap for a premium tactile feedback
class AnimatedScaleTap extends StatefulWidget {
  const AnimatedScaleTap({
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleValue = 0.95,
    this.duration,
    this.curve,
    this.enabled = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleValue;
  final Duration? duration;
  final Curve? curve;
  final bool enabled;

  @override
  State<AnimatedScaleTap> createState() => _AnimatedScaleTapState();
}

class _AnimatedScaleTapState extends State<AnimatedScaleTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? LogistixAnimations.buttonPress,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: widget.scaleValue).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve ?? LogistixAnimations.smooth,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.enabled) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.enabled) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled ? widget.onTap : null,
      onLongPress: widget.enabled ? widget.onLongPress : null,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
