import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/utils/env_config.dart';
import 'package:logistix/core/constants/global_instances.dart';

extension ContextExtension on Ref {
  Dio autoDisposeDio() {
    final dio = Dio();

    if (EnvConfig.instance.isDev) {
      dio.options.extra.addAll({'debug-id': uuid.v1()});
      debugPrint('autoDispose Dio id: ${dio.options.extra['debug-id']}');
    }

    onDispose(() {
      dio.close(force: true);
    });
    return dio;
  }
}
