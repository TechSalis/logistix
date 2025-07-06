import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
              restorationScopeId: 'app',
              // showPerformanceOverlay: kDebugMode || kProfileMode,
              routerConfig: router,
              theme: MyTheme.light,
              darkTheme: MyTheme.dark,
              // themeMode: ThemeMode.dark,
            ),
          ),
        ),
      ),
    );
  }
}

Future precacheData() {
  return Future.wait([
    rootBundle.loadString('assets/json/google_map_theme.dark.json'),
    rootBundle.loadString('assets/json/google_map_theme.light.json'),
    setupGoogleFonts(),
  ]);
}

void setupLicenses() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(
      'assets/google_fonts/Inter/OFL.txt',
    );
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
}

Future setupGoogleFonts() {
  GoogleFonts.config.allowRuntimeFetching = false;
  return GoogleFonts.pendingFonts([GoogleFonts.interTextTheme()]);
}
