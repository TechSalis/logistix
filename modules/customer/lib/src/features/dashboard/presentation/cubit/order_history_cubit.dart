import 'dart:async';
import 'package:customer/src/domain/repositories/customer_order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'order_history_cubit.freezed.dart';

@freezed
abstract class OrderHistoryState with _$OrderHistoryState {
  const factory OrderHistoryState({
    required List<Order> orders,
    required bool isLoading,
    required bool isLoadingMore,
    required bool hasMore,
    String? error,
  }) = _OrderHistoryState;

  factory OrderHistoryState.initial() => const OrderHistoryState(
    orders: [],
    isLoading: false,
    isLoadingMore: false,
    hasMore: true,
  );
}

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  OrderHistoryCubit(this._repo) : super(OrderHistoryState.initial()) {
    _subscribeToOrders();
    refresh();
  }

  final CustomerOrderRepository _repo;
  StreamSubscription<List<Order>>? _subscription;

  int _loadedLimit = _pageSize;
  static const int _pageSize = 20;

  void _subscribeToOrders() {
    _subscription?.cancel();
    _subscription = _repo
        .watchOrders(limit: _loadedLimit)
        .listen((orders) {
          final hasMore = orders.length >= _loadedLimit;
          emit(state.copyWith(
            orders: orders,
            hasMore: hasMore,
            isLoading: false,
          ),);
        });
  }

  Future<void> refresh() async {
    // SessionManager handles background sync, but we specify loading state for UI
    emit(state.copyWith(isLoading: true, error: null));
    // For now we just wait a bit or assume sync is happening. 
    // In a real app, we might call a sync method on SessionManager.
    await Future<void>.delayed(const Duration(milliseconds: 500));
    emit(state.copyWith(isLoading: false));
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    _loadedLimit += _pageSize;
    emit(state.copyWith(isLoadingMore: true));
    
    // Re-subscribe with larger limit to pull from local DB
    _subscribeToOrders();
    
    emit(state.copyWith(isLoadingMore: false));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
