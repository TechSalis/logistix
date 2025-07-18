import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/services/app_data_cache.dart';

final appCacheProvider = Provider.autoDispose<AppDataCache>(
  (ref) => AppDataCache(),
);
