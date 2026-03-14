import 'package:bootstrap/definitions/app_error.dart';
import 'package:shared/shared.dart';

abstract class MetricsRemoteDataSource {
  Future<MetricsDto> getMetrics();
}

class MetricsRemoteDataSourceImpl implements MetricsRemoteDataSource {
  MetricsRemoteDataSourceImpl(this._gqlService);
  final GraphQLService _gqlService;

  @override
  Future<MetricsDto> getMetrics() async {
    const query = '''
      query GetDeliveryMetrics {
        deliveryMetrics {
          totalOrders
          pendingOrders
          inProgressOrders
          deliveredOrders
          codExpectedToday
          onlineRiders
          avgDeliveryTime
        }
      }
    ''';
    final result = await _gqlService.query(query);
    if (result.hasException) {
      throw ErrorHandler.fromException(result.exception);
    }
    final data = result.data?['deliveryMetrics'];
    if (data == null) {
      throw const AppError(message: 'No metrics data returned from server');
    }
    return MetricsDto.fromJson(data as Map<String, dynamic>);
  }
}
