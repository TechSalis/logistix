import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/__debug_tools/leak_tracker.dart';
import 'package:logistix/app/app.dart';
import 'package:logistix/core/utils/env_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  appSetup();
  await Future.wait([
    dotenv.load(fileName: '.env.dev').then((_) {
      EnvConfig.extract(dotenv.env);
      return Supabase.initialize(
        url: EnvConfig.instance.supabaseUrl,
        anonKey: EnvConfig.instance.supabaseAnonKey,
      );
    }),
    Hive.initFlutter(),
    precacheData(),
  ]);
  trackLeaks();

  runApp(const MainApp());
}
