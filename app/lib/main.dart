import 'package:adapters/adapters.dart';
import 'package:bootstrap/interfaces/di/di.dart';
import 'package:flutter/material.dart';
import 'package:logistix/core/init/init.dart';
import 'package:logistix/core/router/app_router.dart';
import 'package:logistix_ux/logistix_ux.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  DI.adapter = GetItDI.new;
  final injector = DI();

  await AppInitialization.init(injector);

  runApp(
    DefaultAssetBundle(
      bundle: SentryAssetBundle(),
      child: LogistixApp(
        appRouter: injector.get<AppRouter>()..startListening(),
      ),
    ),
  );
}

class LogistixApp extends StatelessWidget {
  const LogistixApp({required this.appRouter, super.key});
  final AppRouter appRouter;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Logistix',
      theme: LogistixTheme.lightTheme,
      routerConfig: appRouter.router,
    );
  }
}
