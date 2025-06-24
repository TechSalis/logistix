import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/__debug_tools/leak_tracker.dart';
import 'package:logistix/app.dart';

void main() async {
  await Future.wait([
    dotenv.load(fileName: '.env.dev').then((_) => setupApp()),
    Hive.initFlutter(),
  ]);
  trackLeaks();
  runApp(const MainApp());
}
