import 'dart:async';

import 'package:customer/src/domain/repositories/customer_order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class OrderHistoryState {
  const OrderHistoryState({
    required this.orders,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    this.error,
  });

  factory OrderHistoryState.initial() => const OrderHistoryState(
    orders: [],
    isLoading: false,
    isLoadingMore: false,
    hasMore: true,
  );

  final List<Order> orders;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  OrderHistoryState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return OrderHistoryState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
    );
  }
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
    
    _subscribeToOrders();
    
    emit(state.copyWith(isLoadingMore: false));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
