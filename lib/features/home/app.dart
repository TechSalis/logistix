import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/features/home/presentation/provider_event_handler.dart';
import 'package:logistix/core/theme/theme.dart';
import 'package:logistix/core/utils/env_config.dart';
import 'package:logistix/core/utils/extensions/hive.dart';
import 'package:logistix/core/utils/app_router.dart';
import 'package:logistix/features/auth/application/logic/auth_session.dart';
import 'package:overlay_support/overlay_support.dart';

// ignore: depend_on_referenced_packages
import 'package:image_picker_android/image_picker_android.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: OverlaySupport.global(
        child: AppProviderScope(
          child: MaterialApp.router(
            restorationScopeId: 'app',
            // showPerformanceOverlay: kDebugMode,
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

Future precacheAssetData() {
  return Future.wait([
    rootBundle.loadString('assets/json/google_map_theme.dark.json'),
    rootBundle.loadString('assets/json/google_map_theme.light.json'),
  ]);
}

Future appPluginsSetup() {
  final imagePickerImplementation = ImagePickerPlatform.instance;
  if (imagePickerImplementation is ImagePickerAndroid) {
    imagePickerImplementation.useAndroidPhotoPicker = true;
  }
  return Future.wait([
    Hive.initFlutter().then((_) => Hive.openAllBoxes()),
    Firebase.initializeApp(),
  ]);
}

Future supabasePluginSetupWithEnv(EnvConfig config) {
  return Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
    //TODO: Add auth access token
    accessToken: () async {
      return (await AuthLocalStore.instance.getSession())?.token;
    },
  );
}
