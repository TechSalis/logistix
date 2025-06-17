import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/app.dart';

void main() async {
  await Future.wait([
    dotenv.load(fileName: '.env.dev').then((value) => setupApp()),
    Hive.initFlutter(),
  ]);
  runApp(const MainApp());
}
