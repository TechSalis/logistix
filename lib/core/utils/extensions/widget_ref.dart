import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/utils/env_config.dart';
import 'package:logistix/core/utils/helpers/global_instances.dart';

extension ContextExtension on Ref {
  Dio autoDisposeDio() {
    final dio = Dio();

    if (EnvConfig.instance.isDev) {
      dio.options.extra.addAll({'debug-id': uuid.v1()});
      log('autoDispose Dio id: ${dio.options.extra['debug-id']}');
    }

    onDispose(() {
      dio.close();
    });
    return dio;
  }
}
