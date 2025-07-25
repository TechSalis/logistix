import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:fresh_dio/fresh_dio.dart';
import 'package:logistix/core/env_config.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/features/auth/domain/entities/user_session.dart';
import 'package:logistix/features/auth/infrastructure/repository/auth_local_store.dart';

class DioClient {
  late final Dio _dio;
  static final DioClient _instance = DioClient._internal();

  static Dio get instance => _instance._dio;

  static final _tokenStore = InMemoryTokenStorage<OAuth2Token>();
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.instance.apiUrl,
        connectTimeout: duration_10s,
        receiveTimeout: duration_10s,
      ),
    );
    _dio.interceptors.addAll([
      Fresh.oAuth2(
        tokenStorage: _tokenStore,
        tokenHeader: (token) {
          return {
            HttpHeaders.authorizationHeader: 'Bearer ${token.accessToken}',
          };
        },
        refreshToken: _onRefreshToken,
      ),
      RetryInterceptor(dio: _dio, logPrint: debugPrint),
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
      InterceptorsWrapper(
        onError: (error, handler) {
          final res =
              error.response ?? Response(requestOptions: error.requestOptions);
          handler.resolve(res);
        },
        onResponse: (options, handler) async {
          if (EnvConfig.instance.isDev) {
            await Future.delayed(
              Duration(milliseconds: 2000 + Random().nextInt(5000)),
            );
          }
          return handler.next(options);
        },
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

extension ResExt on Response {
  bool isSuccess() {
    return statusCode != null && statusCode! >= 200 && statusCode! < 300;
  }

  Either<AppError, T> toAppErrorOr<T>(T Function(Response res) response) {
    try {
      if (isSuccess()) return Either.success(response(this));
    } catch (e) {
      return Either.fail(BusinessError(e.toString()));
    }

    try {
      if (data is AppError) return Either.fail(data);
      if (data == null) return Either.fail(AppError.unknown());
      return Either.fail(NetworkError.fromResponse(this));
    } catch (e) {
      return Either.fail(NetworkError(e.toString()));
    }
  }
}

extension DioExceptionExt on FutureOr<Response> {
  Future<Response<dynamic>> handleDioException() async {
    try {
      return await this;
    } on DioException catch (e) {
      final message = switch (e.type) {
        DioExceptionType.connectionTimeout => "Connection timed out",
        DioExceptionType.sendTimeout => "Send timed out",
        DioExceptionType.receiveTimeout => "Receive timed out",
        DioExceptionType.badResponse =>
          "Bad request: ${e.response?.statusMessage}",
        DioExceptionType.cancel => "Request cancelled",
        DioExceptionType.connectionError => "Connection error",
        DioExceptionType.unknown => "Unknown error: ${e.message}",
        DioExceptionType.badCertificate => "Bad SSL Certificate",
      };

      return Response(
        requestOptions: e.requestOptions,
        data: NetworkError(
          message,
          statusCode: e.response?.statusCode ?? -1,
          type: e.type,
        ),
      );
    }
  }
}
