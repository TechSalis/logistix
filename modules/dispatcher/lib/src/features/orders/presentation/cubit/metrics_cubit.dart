import 'dart:async';

import 'package:dispatcher/src/features/orders/data/dtos/dispatcher_metrics_dto.dart';
import 'package:dispatcher/src/features/orders/domain/repositories/metrics_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MetricsState {
  MetricsState({required this.isLoading, this.metrics, this.error});

  factory MetricsState.initial() => MetricsState(isLoading: false);

  final DispatcherMetricsDto? metrics;
  final bool isLoading;
  final String? error;

  MetricsState copyWith({
    DispatcherMetricsDto? metrics,
    bool? isLoading,
    String? error,
  }) => MetricsState(
    metrics: metrics ?? this.metrics,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class MetricsCubit extends Cubit<MetricsState> {
  MetricsCubit(this._repo) : super(MetricsState.initial()) {
    _subscribeToMetrics();
  }

  final MetricsRepository _repo;
  StreamSubscription<DispatcherMetricsDto?>? _metricsSubscription;

  void _subscribeToMetrics() {
    emit(state.copyWith(isLoading: true));

    _metricsSubscription?.cancel();
    _metricsSubscription = _repo.watchMetrics().listen(
      (metrics) {
        if (isClosed) return;
        emit(state.copyWith(isLoading: false, metrics: metrics));
      },
      onError: (Object error) {
        if (isClosed) return;
        emit(
          state.copyWith(isLoading: false, error: 'Failed to fetch metrics'),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _metricsSubscription?.cancel();
    return super.close();
  }
}
