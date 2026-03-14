abstract class LogistixDurations {
  // Animation durations (in milliseconds)
  static const int instant = 0;
  static const int fastest = 100;
  static const int fast = 200;
  static const int normal = 300;
  static const int moderate = 400;
  static const int slow = 500;
  static const int slower = 700;
  static const int slowest = 1000;

  // Semantic durations
  static const int pageTransition = normal;
  static const int dialogTransition = fast;
  static const int buttonPress = fastest;
  static const int shimmer = slower;
  static const int tooltipDelay = moderate;
  static const int snackbarDuration = 3000;
}
