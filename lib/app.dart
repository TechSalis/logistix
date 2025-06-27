import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/core/constants/theme.dart';
import 'package:logistix/core/utils/router.dart';
import 'package:logistix/features/notifications/presentation/widgets/notification_listener_widget.dart';
import 'package:overlay_support/overlay_support.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: ProviderScope(
        child: OverlaySupport.global(
          child: ProviderAppNotificationsListener(
            child: MaterialApp.router(
              // showPerformanceOverlay: kDebugMode || kProfileMode,
              routerConfig: router,
              theme: MyTheme.light,
              darkTheme: MyTheme.dark,
              themeMode: ThemeMode.dark,
            ),
          ),
        ),
      ),
    );
  }
}
