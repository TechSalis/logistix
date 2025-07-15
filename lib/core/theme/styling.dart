// ignore_for_file: constant_identifier_names

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

const padding_8 = EdgeInsets.all(8);
const padding_16 = EdgeInsets.all(16);
const padding_24 = EdgeInsets.all(24);
const padding_H12 = EdgeInsets.symmetric(horizontal: 12);
const padding_H16 = EdgeInsets.symmetric(horizontal: 16);
const padding_H16_V8 = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
const padding_H16_V12 = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

const borderRadius_8 = BorderRadius.all(Radius.circular(8));
const borderRadius_12 = BorderRadius.all(Radius.circular(12));
const borderRadius_16 = BorderRadius.all(Radius.circular(16));
const borderRadius_24 = BorderRadius.all(Radius.circular(24));
const borderRadius_32 = BorderRadius.all(Radius.circular(32));

const roundRectBorder8 = RoundedRectangleBorder(borderRadius: borderRadius_8);
const roundRectBorder16 = RoundedRectangleBorder(borderRadius: borderRadius_16);
