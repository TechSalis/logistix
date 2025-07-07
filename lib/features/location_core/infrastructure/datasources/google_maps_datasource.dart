import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:logistix/core/utils/env_config.dart';
import 'package:logistix/core/constants/global_instances.dart';
import 'package:logistix/features/location_core/domain/entities/place.dart';
import 'package:logistix/features/location_core/infrastructure/dtos/google_map_response_dtos.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';

class GoogleMapsDatasource {
  final Dio _dio;
  GoogleMapsDatasource(this._dio) {
    // TODO: sessionToken = uuid.v4();

    _dio.interceptors.addAll([
      dioCacheInterceptor,
      RetryInterceptor(dio: _dio, logPrint: print),
    ]);
    _dio.options = BaseOptions(
      baseUrl: EnvConfig.instance.googleMapApiUrl,
      headers: {
        // 'X-Goog-Api-Key': EnvConfig.instance.googleApiKey,
        'Content-Type': 'application/json',
      },
      queryParameters: {'region': 'ng', 'key': EnvConfig.instance.googleApiKey},
    );
  }

  Future<List<Place>> getAddressProperties(Coordinates query) async {
    final res = await _dio.get(
      '/geocode/json',
      queryParameters: {
        "latlng": '${query.latitude}, ${query.longitude}',
        'location_type': 'ROOFTOP|RANGE_INTERPOLATED',
        'result_type':
            'street_address|route|airport|point_of_interest|neighborhood',
      },
    );

    final data =
        (res.data!['results'] as List)
            .cast<Map<String, dynamic>>()
            .map(PlaceModel.geocode)
            .toList();

    return data;
  }
}
