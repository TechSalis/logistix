import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logistix/core/constants/hive_constants.dart';

class AppDataCache {  

  final box = Hive.box(HiveConstants.app);

  bool get isFirstLogin => box.get('isFirstLogin', defaultValue: true);
  set isFirstLogin(bool value) => box.put('isFirstLogin', value);
}


final appCacheProvider = Provider.autoDispose<AppDataCache>(
  (ref) => AppDataCache(),
);
