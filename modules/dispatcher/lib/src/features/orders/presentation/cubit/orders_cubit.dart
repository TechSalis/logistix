import 'dart:async';
import 'package:bootstrap/services/debouncer.dart';
import 'package:dispatcher/src/domain/repositories/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'orders_cubit.freezed.dart';

@freezed
abstract class OrdersState with _$OrdersState {
  const factory OrdersState({
    required List<Order> orders,
    required bool isSearching,
    required bool isLoading,
    required bool isLoadingMore,
    required bool hasMore,
    OrderStatus? selectedStatus,
    String? searchQuery,
    String? error,
  }) = _OrdersState;

  factory OrdersState.initial() => const OrdersState(
    orders: [],
    isSearching: false,
    isLoading: false,
    isLoadingMore: false,
    hasMore: true,
  );
}

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repo) : super(OrdersState.initial()) {
    scrollController = ScrollController()..addListener(_onScroll);
    _subscribeToOrders();
  }

  final OrderRepository _repo;
  late final ScrollController scrollController;

  StreamSubscription<List<Order>>? _ordersSubscription;
  final _debouncer = Debouncer();

  int _loadedLimit = _pageSize;
  bool _isLoadingMore = false;

  static const int _pageSize = 20;

  void _subscribeToOrders() {
    if (isClosed) return;

    _ordersSubscription?.cancel();

    // Subscribe to Drift stream - reactive to all changes
    // We watch from 0 up to current loaded limit to stay reactive
    _ordersSubscription = _repo
        .watchOrders(
          status: state.selectedStatus != null ? [state.selectedStatus!] : null,
          searchQuery: state.searchQuery,
          limit: _loadedLimit,
        )
        .listen((orders) {
          if (!isClosed) {
            final hasMore = orders.length >= _loadedLimit;
            emit(
              state.copyWith(
                orders: orders,
                hasMore: hasMore,
                isLoading: false,
              ),
            );
          }
        });
  }

  void filterByStatus(OrderStatus? status) {
    _loadedLimit = _pageSize; // Reset pagination
    emit(state.copyWith(selectedStatus: status, orders: [], isLoading: true));
    _subscribeToOrders(); // Re-subscribe with new filters
  }

  void searchOrders(String query) {
    emit(state.copyWith(isSearching: true));

    _debouncer.debounce(
      duration: const Duration(milliseconds: 500),
      onDebounce: () {
        if (isClosed) return;
        _loadedLimit = _pageSize; // Reset pagination on search
        emit(
          state.copyWith(searchQuery: query, isSearching: false, orders: []),
        );
        _subscribeToOrders(); // Re-subscribe with search query
      },
    );
  }

  void loadMore() {
    if (_isLoadingMore || !state.hasMore) return;

    _isLoadingMore = true;
    _loadedLimit += _pageSize;

    emit(state.copyWith(isLoadingMore: true));

    // Just re-subscribe with larger limit.
    // Reactive stream will emit new list with more items.
    _subscribeToOrders();

    // Reset loading state after a short delay (or wait for first emit but sub is enough)
    _isLoadingMore = false;
    emit(state.copyWith(isLoadingMore: false));
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    const threshold = 200.0;
    final position = scrollController.position;
    if (position.maxScrollExtent - position.pixels <= threshold) {
      loadMore();
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    scrollController.dispose();
    return super.close();
  }
}
