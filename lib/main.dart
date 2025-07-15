import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logistix/features/home/app.dart';
import 'package:logistix/core/utils/env_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  /// TODO: Show splash screen and pre-initialize data
  await Future.wait([
    appPluginsSetup(),
    dotenv.load(fileName: '.env.prod').then((_) {
      EnvConfig.extract(dotenv.env);
      return supabasePluginSetupWithEnv(EnvConfig.instance);
    }),
    precacheAssetData(),
  ]);

  runApp(const MainApp());
}
