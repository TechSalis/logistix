import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget materialAppWrapper({Widget? child}) {
  return ScreenUtilInit(child: MaterialApp(home: Material(child: child)));
}
