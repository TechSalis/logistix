import 'package:dispatcher/src/domain/repositories/metrics_repository.dart';
import 'package:shared/shared.dart';

class MetricsRepositoryImpl implements MetricsRepository {
  MetricsRepositoryImpl(this._database, this._userStore);

  final LogistixDatabase _database;
  final UserStore _userStore;

  @override
  Stream<DispatcherMetricsDto?> watchMetrics() async* {
    final user = await _userStore.getUser();
    final companyId = user?.companyId;

    if (companyId == null) {
      yield null;
      return;
    }

    yield* _database.watchDispatcherMetrics(companyId).map((data) {
      if (data == null) return null;

      return DispatcherMetricsDto(
        activeOrders: data.activeOrders,
        unassignedOrders: data.unassignedOrders,
        assignedOrders: data.assignedOrders,
        enRouteOrders: data.enRouteOrders,
        onlineRidersCount: data.onlineRidersCount,
        busyRidersCount: data.busyRidersCount,
      );
    });
  }
}
