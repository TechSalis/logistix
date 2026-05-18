import 'dart:async';

import 'package:customer/src/domain/repositories/customer_delivery_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class DeliveryHistoryState {
  const DeliveryHistoryState({
    required this.deliveries,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    this.error,
  });

  factory DeliveryHistoryState.initial() => const DeliveryHistoryState(
    deliveries: [],
    isLoading: false,
    isLoadingMore: false,
    hasMore: true,
  );

  final List<Delivery> deliveries;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  DeliveryHistoryState copyWith({
    List<Delivery>? deliveries,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return DeliveryHistoryState(
      deliveries: deliveries ?? this.deliveries,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
}

class DeliveryHistoryCubit extends Cubit<DeliveryHistoryState> {
  DeliveryHistoryCubit(this._repo) : super(DeliveryHistoryState.initial()) {
    _subscribeToDeliveries();
    refresh();
  }

  final CustomerDeliveryRepository _repo;
  StreamSubscription<List<Delivery>>? _subscription;

  int _loadedLimit = _pageSize;
  static const int _pageSize = 20;

  void _subscribeToDeliveries() {
    _subscription?.cancel();
    _subscription = _repo
        .watchDeliveries(limit: _loadedLimit)
        .listen((deliveries) {
          final hasMore = deliveries.length >= _loadedLimit;
          emit(state.copyWith(
            deliveries: deliveries,
            hasMore: hasMore,
            isLoading: false,
          ));
        });
  }

  Future<void> refresh() async {
    emit(state.copyWith(isLoading: true));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(isLoading: false));
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    _loadedLimit += _pageSize;
    emit(state.copyWith(isLoadingMore: true));
    
    _subscribeToDeliveries();
    
    emit(state.copyWith(isLoadingMore: false));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
