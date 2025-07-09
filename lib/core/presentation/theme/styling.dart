import 'package:flutter/material.dart';

extension StylingData on BuildContext {
  BoxDecoration get boxDecorationWithShadow => BoxDecoration(
    color: Theme.of(this).bottomSheetTheme.backgroundColor,
    boxShadow: [
      BoxShadow(
        blurRadius: Theme.of(this).bottomSheetTheme.elevation!,
        color: Theme.of(this).bottomSheetTheme.shadowColor!,
      ),
    ],
  );
}

