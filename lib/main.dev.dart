import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logistix/app/app.dart';
import 'package:logistix/core/env_config.dart';
import 'package:logistix/firebase_options_dev.dart';

import 'package:logistix/__debug_tools/track_leaks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Future.wait([
    appPluginsSetup(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    dotenv.load(fileName: 'dev.env').then((_) {
      EnvConfig.extract(dotenv.env);
      return supabasePluginSetupWithEnv(EnvConfig.instance);
    }),
  ]);
  // await Hive.deleteFromDisk();

  trackLeaks();
  runApp(const MainApp());
}
