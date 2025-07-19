import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:logistix/core/env_config.dart';
import 'package:logistix/features/auth/domain/entities/user_session.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_local_store.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  static Dio get instance => _instance.dio;
  late final Dio dio;

  static final _tokenStore = InMemoryTokenStorage<OAuth2Token>();

  DioClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.instance.apiUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    dio.interceptors.addAll([
      Fresh.oAuth2(
        tokenStorage: _tokenStore,
        tokenHeader: (token) {
          return {
            HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}',
          };
        },
        refreshToken: _onRefreshToken,
      ),
      RetryInterceptor(dio: dio, logPrint: debugPrint),
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    ]);
  }

  Future<OAuth2Token> _onRefreshToken(OAuth2Token? token, Dio dio) async {
    final res = await dio.post(
      '${EnvConfig.instance.apiUrl}/auth/refresh',
      data: {'refresh_token': token?.refreshToken},
      options: Options(
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${token?.accessToken}',
        },
      ),
    );
    final session = AuthSessionModel.fromJson(res.data);
    AuthLocalStore.instance.saveSession(session);
    return session.toOAuth2Token();
  }

  static void updateSession(AuthSession? session) {
    if (session == null) {
      _tokenStore.delete();
    } else {
      _tokenStore.write(session.toOAuth2Token());
    }
  }
}

extension _SessionToOAuth2Token on AuthSession {
  OAuth2Token toOAuth2Token() {
    return OAuth2Token(accessToken: token, refreshToken: refreshToken);
  }
}
