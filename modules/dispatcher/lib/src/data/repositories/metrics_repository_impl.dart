import 'package:bootstrap/interfaces/store/store.dart';
import 'package:dispatcher/src/domain/repositories/metrics_repository.dart';
import 'package:shared/shared.dart';

class MetricsRepositoryImpl implements MetricsRepository {
  MetricsRepositoryImpl(this._metricsStore);

  final StreamableObjectStore<DispatcherMetricsDto> _metricsStore;

  @override
  Stream<DispatcherMetricsDto?> watchMetrics() async* {
    yield await _metricsStore.get();
    yield* _metricsStore.watch();
  }
}
