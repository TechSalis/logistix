import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/material.dart';
import 'package:logistix/core/env_config.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/location_core/domain/entities/place.dart';
import 'package:logistix/features/location_core/infrastructure/dtos/google_map_response_dtos.dart';

class GooglePlacesDatasource {
  final Dio _dio;
  GooglePlacesDatasource(this._dio) {
    // TODO: sessionToken = uuid.v4();

    _dio.interceptors.addAll([
      DioCacheInterceptor(
        options: CacheOptions(
          store: MemCacheStore(),
          policy: CachePolicy.forceCache,
          hitCacheOnNetworkFailure: true,
          maxStale: const Duration(days: 1),
        ),
      ),
      RetryInterceptor(dio: _dio, logPrint: debugPrint),
    ]);
    _dio.options = BaseOptions(
      baseUrl: EnvConfig.instance.googlePlaceApiUrl,
      connectTimeout: duration_10s,
      receiveTimeout: duration_10s,
      headers: {
        'X-Goog-Api-Key': EnvConfig.instance.googleApiKey,
        'Content-Type': 'application/json',
      },
      queryParameters: {'regionCode': 'ng'},
    );
  }

  Future<List<Place>> suggestions(
    String query,
    Coordinates locationBias,
  ) async {
    final res = await _dio.post(
      '/:autocomplete',
      data: {
        "input": query,
        "locationBias": {
          "circle": {
            "center": {
              'latitude': locationBias.latitude,
              'longitude': locationBias.longitude,
            },
            "radius": 50000,
          },
        },
      },
      options: Options(
        headers: {
          'X-Goog-FieldMask':
              'suggestions.placePrediction.placeId,suggestions.placePrediction.text.text',
        },
      ),
    );

    final data =
        (res.data!['suggestions'] as List?)
            ?.cast<Map<String, dynamic>>()
            .map((e) => PlaceModel.suggestion(e['placePrediction']))
            .toList();

    return data ?? [];
  }

  Future<PlaceDetails> place(String placeId) async {
    final res = await _dio.get(
      '/$placeId',
      options: Options(
        headers: {
          'X-Goog-FieldMask': 'id,displayName,formattedAddress,location',
        },
      ),
    );

    final data = PlaceDetailsModel.place(res.data);
    return data;
  }
}
