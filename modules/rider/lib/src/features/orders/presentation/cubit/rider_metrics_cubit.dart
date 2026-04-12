import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:rider/src/features/orders/data/dtos/rider_metrics_dto.dart';

class RiderMetricsState {
  RiderMetricsState({required this.isLoading, this.metrics, this.error});

  factory RiderMetricsState.initial() => RiderMetricsState(isLoading: true);

  final RiderMetricsDto? metrics;
  final bool isLoading;
  final String? error;

  RiderMetricsState copyWith({
    RiderMetricsDto? metrics,
    bool? isLoading,
    String? error,
  }) => RiderMetricsState(
    metrics: metrics ?? this.metrics,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class RiderMetricsCubit extends Cubit<RiderMetricsState> {
  RiderMetricsCubit(this._repo) : super(RiderMetricsState.initial()) {
    _subscribeToMetrics();
  }

  final RiderRepository _repo;
  StreamSubscription<RiderMetricsDto?>? _metricsSubscription;

  void _subscribeToMetrics() {
    _metricsSubscription?.cancel();
    _metricsSubscription = _repo.watchRiderMetrics().listen(
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
