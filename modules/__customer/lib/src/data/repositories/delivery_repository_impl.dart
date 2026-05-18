import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/definitions/result.dart';
import 'package:customer/src/data/datasources/delivery_remote_datasource.dart';
import 'package:customer/src/data/dtos/customer_delivery_input.dart';
import 'package:customer/src/domain/repositories/customer_delivery_repository.dart';
import 'package:shared/shared.dart';

class CustomerDeliveryRepositoryImpl implements CustomerDeliveryRepository {
  const CustomerDeliveryRepositoryImpl({
    required CustomerDeliveryRemoteDataSource remoteDataSource,
    required DeliveryDao deliveryDao,
    required UserStore userStore,
  }) : _remoteDataSource = remoteDataSource,
       _deliveryDao = deliveryDao,
       _userStore = userStore;

  final CustomerDeliveryRemoteDataSource _remoteDataSource;
  final DeliveryDao _deliveryDao;
  final UserStore _userStore;

  @override
  Stream<List<Delivery>> watchDeliveries({int limit = 20, int offset = 0}) {
    final userId = _userStore.user?.id;
    return _deliveryDao.watchDeliveries(
      createdBy: userId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Stream<Delivery?> watchDelivery(String id) => _deliveryDao.watchDelivery(id);

  @override
  Future<Result<AppError, Delivery>> createDelivery(CustomerDeliveryInput input) async {
    return Result.tryCatch(() async {
      final dto = await _remoteDataSource.createDelivery(input);
      
      // Save to local DB promptly
      await _deliveryDao.upsertDelivery(dto.toDriftCompanion());
      
      return dto.toEntity();
    });
  }
}
