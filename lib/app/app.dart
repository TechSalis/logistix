import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:logistix/core/theme/theme.dart';
import 'package:logistix/core/utils/router.dart';
import 'package:logistix/features/notifications/presentation/widgets/notification_listener_widget.dart';
import 'package:overlay_support/overlay_support.dart';

// ignore: depend_on_referenced_packages
import 'package:image_picker_android/image_picker_android.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: ProviderScope(
        child: OverlaySupport.global(
          child: ProviderAppNotificationsHandler(
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
      ),
    );
  }
}

Future precacheData() {
  return Future.wait([
    rootBundle.loadString('assets/json/google_map_theme.dark.json'),
    rootBundle.loadString('assets/json/google_map_theme.light.json'),
  ]);
}

void appSetup() {
  WidgetsFlutterBinding.ensureInitialized();
  final imagePickerImplementation = ImagePickerPlatform.instance;
  if (imagePickerImplementation is ImagePickerAndroid) {
    imagePickerImplementation.useAndroidPhotoPicker = true;
  }
}
