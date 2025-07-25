import 'package:dio/dio.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/either.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/rider/domain/repository/rider_repo.dart';
import 'package:logistix/features/rider/infrastructure/models/rider_data_dto.dart';

class RiderRepoImpl extends RiderRepo {
  RiderRepoImpl({required this.client});
  final Dio client;

  @override
  Stream<Coordinates> listenToRiderCoordinates(RiderData rider) {
    // TODO: implement listenToRiderCoordinates
    throw UnimplementedError();
  }

  @override
  Future<Either<AppError, Iterable<RiderData>>> findRiders([
    Coordinates? location,
  ]) async {
    final res =
        await client
            .get('/riders/nearest', queryParameters: location?.toJson())
            .handleDioException();

    return res.toAppErrorOr((res) {
      return List.from(res.data).map((e) => RiderDataModel.fromJson(e));
    });
  }
}
