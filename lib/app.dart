import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/core/utils/env_config.dart';
import 'package:logistix/core/constants/theme.dart';
import 'package:logistix/core/utils/router.dart';
import 'package:overlay_support/overlay_support.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: ProviderScope(
        child: OverlaySupport.global(
          child: MaterialApp.router(
            routerConfig: router,
            theme: MyTheme.light,
            darkTheme: MyTheme.dark,
            // themeMode: ThemeMode.dark,
          ),
        ),
      ),
    );
  }
}

void setupApp() {
  EnvConfig.extract(dotenv.env);
  // MapboxOptions.setAccessToken(EnvConfig.instance.mapboxToken);
}
