import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/app.dart';

void main() async {
  /// TODO: Show splash screen and initialize data
  /// - location data
  await Future.wait([
    dotenv.load(fileName: '.env.prod').then((_) => setupApp()),
    Hive.initFlutter(),
  ]);
  runApp(const MainApp());
}
