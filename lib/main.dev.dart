import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logistix/__debug_tools/track_leaks.dart';
import 'package:logistix/app/app.dart';
import 'package:logistix/core/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Future.wait([
    appPluginsSetup(),
    dotenv.load(fileName: 'dev.env').then((_) {
      EnvConfig.extract(dotenv.env);
      return supabasePluginSetupWithEnv(EnvConfig.instance);
    }),
  ]);
  // await Hive.deleteFromDisk();

  trackLeaks();
  runApp(const MainApp());
}
