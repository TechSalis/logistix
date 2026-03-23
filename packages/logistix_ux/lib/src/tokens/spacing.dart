abstract class LogistixSpacing {
  // Base unit: 4px
  static const double unit = 4;

  // Spacing scale
  static const double xxs = unit; // 4
  static const double xs = unit * 2; // 8
  static const double sm = unit * 3; // 12
  static const double md = unit * 4; // 16
  static const double lg = unit * 6; // 24
  static const double xl = unit * 8; // 32
  static const double xxl = unit * 12; // 48
  static const double xxxl = unit * 16; // 64

  // Semantic spacing
  static const double elementGap = xs; // 8
  static const double sectionGap = md; // 16
  static const double pageGap = lg; // 24
  static const double pagePadding = lg; // 24

  // Component-specific spacing
  static const double cardPadding = lg; // Increased to 24px
  static const double buttonPaddingVertical = md; // Increased to 16px
  static const double buttonPaddingHorizontal = xl; // Increased to 32px
  static const double inputPaddingVertical = sm; // 12
  static const double inputPaddingHorizontal = md; // 16
  static const double listItemPadding = md; // 16

  // Layout spacing
  static const double screenPaddingHorizontal = lg; // 24
  static const double screenPaddingVertical = lg; // 24
  static const double maxContentWidth = 1200;
  static const double sidebarWidth = 280;
}
