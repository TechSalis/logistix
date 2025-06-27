import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/app.dart';
import 'package:logistix/core/utils/env_config.dart';
import 'package:logistix/features/map/presentation/widgets/google_map_widget.dart';

void main() async {
  /// TODO: Show splash screen and initialize data
  /// - location data
  await Future.wait([
    dotenv
        .load(fileName: '.env.prod')
        .then((_) => EnvConfig.extract(dotenv.env)),
    Hive.initFlutter(),
    precacheMapData(),
  ]);
  runApp(const MainApp());
}
