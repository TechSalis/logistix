import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/app/observers/provider_event_handler.dart';
import 'package:logistix/core/theme/theme.dart';
import 'package:logistix/core/env_config.dart';
import 'package:logistix/core/utils/extensions/hive.dart';
import 'package:logistix/app/router/app_router.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_local_store.dart';
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

Future appPluginsSetup() async {
  final imagePickerImplementation = ImagePickerPlatform.instance;
  if (imagePickerImplementation is ImagePickerAndroid) {
    imagePickerImplementation.useAndroidPhotoPicker = true;
  }
  await Hive.initFlutter().then((_) {
    return Future.wait([Hive.openStartupBoxes(), Hive.openTrackedBoxes()]);
  });
}

Future supabasePluginSetupWithEnv(EnvConfig config) {
  return Supabase.initialize(
    url: 'https://rrlvhszexjszxcoesilp.supabase.co',
    anonKey: config.supabaseAnonKey,
    accessToken: () {
      return Future.value(AuthLocalStore.instance.getSession()?.token);
    },
  );
}
