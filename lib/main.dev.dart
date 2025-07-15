import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logistix/__debug_tools/leak_tracker.dart';
import 'package:logistix/features/home/app.dart';
import 'package:logistix/core/utils/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Future.wait([
    appPluginsSetup(),
    dotenv.load(fileName: '.env.dev').then((_) {
      EnvConfig.extract(dotenv.env);
      return supabasePluginSetupWithEnv(EnvConfig.instance);
    }),
    precacheAssetData(),
  ]);

  trackLeaks();
  runApp(const MainApp());
}
