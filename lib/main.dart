import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/app/app.dart';
import 'package:logistix/core/utils/env_config.dart';

void main() async {
  /// TODO: Show splash screen and pre-initialize data
  await Future.wait([
    appSetup(),
    dotenv.load(fileName: '.env.prod').then((_) {
      EnvConfig.extract(dotenv.env);
      return appSetupWithEnv();
    }),
    Hive.initFlutter(),
    precacheData(),
  ]);
  runApp(const MainApp());
}
