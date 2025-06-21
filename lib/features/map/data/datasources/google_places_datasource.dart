import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:logistix/core/utils/env_config.dart';
import 'package:logistix/core/utils/helpers/global_instances.dart';
import 'package:logistix/features/map/data/dto/google_map_response_dtos.dart';

class GooglePlacesDatasource {
  final Dio _dio;
  GooglePlacesDatasource(this._dio) {
    // sessionToken = uuid.v4();

    _dio.interceptors.addAll([
      dioCacheInterceptor,
      RetryInterceptor(dio: _dio, logPrint: print),
    ]);
    _dio.options = BaseOptions(
      baseUrl: EnvConfig.instance.googlePlaceApiUrl,
      // connectTimeout: const Duration(seconds: 10),
      headers: {
        'X-Goog-Api-Key': EnvConfig.instance.googleApiKey,
        'Content-Type': 'application/json',
      },
      queryParameters: {'regionCode': 'ng'},
    );
  }

  Future<List<Place>> suggestions(String query) async {
    final res = await _dio.post(
      ':autocomplete',
      data: {"input": query},
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
      placeId,
      options: Options(headers: {'X-Goog-FieldMask': 'id,displayName,formattedAddress,location'}),
    );

    final data = PlaceDetailsModel.place(res.data);
    return data;
  }
}
