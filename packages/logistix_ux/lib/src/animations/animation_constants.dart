import 'package:flutter/animation.dart';
import 'package:logistix_ux/src/tokens/durations.dart';

abstract class LogistixAnimations {
  // Standard Curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve linear = Curves.linear;

  // Custom Enterprise Curves (smooth, premium feel)
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve smoothFast = Curves.easeOutCubic;
  static const Curve smoothSlow = Curves.easeInCubic;

  // Bouncy curves (for delightful interactions)
  static const Curve bounce = Curves.elasticOut;
  static const Curve bounceSoft = Curves.easeOutBack;

  // Sharp curves (for crisp, responsive feel)
  static const Curve sharp = Curves.easeOutExpo;
  static const Curve sharpIn = Curves.easeInExpo;

  // Emphasized curves (Material 3 inspired)
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0, 0.8, 0.15);

  // Durations
  static const Duration instant = Duration.zero;
  static const Duration fastest = Duration(
    milliseconds: LogistixDurations.fastest,
  );
  static const Duration fast = Duration(milliseconds: LogistixDurations.fast);
  static const Duration normal = Duration(
    milliseconds: LogistixDurations.normal,
  );
  static const Duration moderate = Duration(
    milliseconds: LogistixDurations.moderate,
  );
  static const Duration slow = Duration(milliseconds: LogistixDurations.slow);
  static const Duration slower = Duration(
    milliseconds: LogistixDurations.slower,
  );
  static const Duration slowest = Duration(
    milliseconds: LogistixDurations.slowest,
  );

  // Semantic durations
  static const Duration pageTransition = Duration(
    milliseconds: LogistixDurations.pageTransition,
  );
  static const Duration dialogTransition = Duration(
    milliseconds: LogistixDurations.dialogTransition,
  );
  static const Duration buttonPress = Duration(
    milliseconds: LogistixDurations.buttonPress,
  );
  static const Duration shimmer = Duration(
    milliseconds: LogistixDurations.shimmer,
  );
}
