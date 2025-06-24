import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:logistix/core/utils/env_config.dart';
import 'package:logistix/core/constants/global_instances.dart';
import 'package:logistix/features/location/infrastructure/dtos/__mapbox_response_dtos.dart';
import 'package:logistix/features/location/domain/entities/coordinate.dart';

class MapBoxDatasource {
  final Dio _dio;
  MapBoxDatasource(this._dio) {
    sessionToken = uuid.v4();

    _dio.interceptors.addAll([
      InterceptorsWrapper(
        onError: (error, handler) {
          switch (error.response?.data) {
            case {"message": {"error": "Session Token is required"}}:
              sessionToken = uuid.v4();
              handler.next(
                error
                  ..requestOptions.queryParameters['session_token'] =
                      sessionToken,
              );
              break;
            default:
          }
        },
      ),
      RetryInterceptor(
        dio: _dio,
        logPrint: print,
        retryableExtraStatuses: {status400BadRequest},
      ),
    ]);
    _dio.options = BaseOptions(
      baseUrl: EnvConfig.instance.mapBoxApiUrl,
      // connectTimeout: const Duration(seconds: 10),
      queryParameters: {
        'country': 'NG',
        'access_token': EnvConfig.instance.mapboxToken,
        'session_token': sessionToken,
      },
    );
  }

  String? sessionToken;

  Future<List<GeoProperties>> getAddressProperties(
    Coordinates coordinate,
  ) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/search/geocode/v6/reverse',
      queryParameters: {
        'types': ['address', 'street', 'postcode','locality', 'place'],
        'longitude': coordinate.longitude,
        'latitude': coordinate.latitude,
      },
    );

    final data =
        (res.data!['features'] as List).map((e) {
          return GeoProperties.fromMap(e['properties']);
        }).toList();

    return data;
  }

  Future<List<GeoProperties>> search(String query) async {
    final res = await _dio.get(
      '/search/geocode/v6/forward',
      queryParameters: {'q': query},
    );

    final data =
        (res.data!['features'] as List).map((e) {
          return GeoProperties.fromMap(e['properties']);
        }).toList();

    return data;
  }

  // Future<List<GeoSearchPlace>> search(String query) async {
  //   final res = await _dio.get(
  //     '/search/searchbox/v1/suggest',
  //     queryParameters: {'q': query},
  //   );

  //   final data =
  //       (res.data!['suggestions'] as List)
  //           .cast<Map<String, dynamic>>()
  //           .map(GeoSearchPlace.fromMap)
  //           .toList();

  //   return data;
  // }
}
