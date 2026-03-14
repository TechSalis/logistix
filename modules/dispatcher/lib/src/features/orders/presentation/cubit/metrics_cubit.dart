import 'dart:async';

import 'package:dispatcher/src/domain/repositories/metrics_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class MetricsState {
  MetricsState({required this.isLoading, this.metrics, this.error});

  factory MetricsState.initial() => MetricsState(isLoading: false);

  final Metrics? metrics;
  final bool isLoading;
  final String? error;

  MetricsState copyWith({Metrics? metrics, bool? isLoading, String? error}) =>
      MetricsState(
        metrics: metrics ?? this.metrics,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class MetricsCubit extends Cubit<MetricsState> {
  MetricsCubit(this._repo) : super(MetricsState.initial());

  final MetricsRepository _repo;

  Future<void> loadMetrics() async {
    emit(state.copyWith(isLoading: true));
    final result = await _repo.getMetrics();
    
    if (isClosed) return;

    result.map(
      (e) => emit(state.copyWith(isLoading: false, error: e.message)),
      (dto) => emit(state.copyWith(isLoading: false, metrics: dto)),
    );
  }

  /// Handle metrics updates from DispatcherSessionManager
  void handleMetricsUpdate(Metrics metrics) {
    emit(state.copyWith(metrics: metrics, isLoading: false));
  }
}
