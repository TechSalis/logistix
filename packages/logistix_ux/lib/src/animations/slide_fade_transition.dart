import 'package:flutter/material.dart';
import 'package:logistix_ux/src/animations/animation_constants.dart';

/// Slide direction for the transition
enum SlideDirection { left, right, up, down }

/// A widget that combines slide and fade animations for smooth transitions
class SlideFadeTransition extends StatelessWidget {
  const SlideFadeTransition({
    required this.child,
    this.visible = true,
    this.duration,
    this.curve,
    this.direction = SlideDirection.up,
    this.offset = 0.2,
    super.key,
  });

  final Widget child;
  final bool visible;
  final Duration? duration;
  final Curve? curve;
  final SlideDirection direction;
  final double offset;

  @override
  Widget build(BuildContext context) {
    final effectiveDuration = duration ?? LogistixAnimations.normal;
    final effectiveCurve = curve ?? LogistixAnimations.emphasizedDecelerate;

    Offset getBeginOffset() {
      switch (direction) {
        case SlideDirection.left:
          return Offset(-offset, 0);
        case SlideDirection.right:
          return Offset(offset, 0);
        case SlideDirection.up:
          return Offset(0, offset);
        case SlideDirection.down:
          return Offset(0, -offset);
      }
    }

    return AnimatedSlide(
      duration: effectiveDuration,
      curve: effectiveCurve,
      offset: visible ? Offset.zero : getBeginOffset(),
      child: AnimatedOpacity(
        duration: effectiveDuration,
        curve: effectiveCurve,
        opacity: visible ? 1.0 : 0.0,
        child: child,
      ),
    );
  }
}

/// A pre-built page route with slide-fade transition
class SlideFadePageRoute<T> extends PageRouteBuilder<T> {
  SlideFadePageRoute({
    required this.child,
    this.direction = SlideDirection.left,
    this.duration,
    this.curve,
    super.settings,
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration ?? LogistixAnimations.pageTransition,
         reverseTransitionDuration:
             duration ?? LogistixAnimations.pageTransition,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           final effectiveCurve = curve ?? LogistixAnimations.emphasized;

           final slideAnimation = Tween<Offset>(
             begin: _getBeginOffset(direction),
             end: Offset.zero,
           ).animate(CurvedAnimation(parent: animation, curve: effectiveCurve));

           final fadeAnimation = Tween<double>(
             begin: 0,
             end: 1,
           ).animate(CurvedAnimation(parent: animation, curve: effectiveCurve));

           return SlideTransition(
             position: slideAnimation,
             child: FadeTransition(opacity: fadeAnimation, child: child),
           );
         },
       );

  final Widget child;
  final SlideDirection direction;
  final Duration? duration;
  final Curve? curve;

  static Offset _getBeginOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.left:
        return const Offset(1, 0);
      case SlideDirection.right:
        return const Offset(-1, 0);
      case SlideDirection.up:
        return const Offset(0, 1);
      case SlideDirection.down:
        return const Offset(0, -1);
    }
  }
}
