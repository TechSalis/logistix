import 'dart:async';
import 'package:bootstrap/services/debouncer.dart';
import 'package:dispatcher/src/features/orders/domain/repositories/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class OrdersState {
  const OrdersState({
    required this.orders,
    required this.isSearching,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    this.selectedStatus,
    this.searchQuery,
    this.error,
  });

  factory OrdersState.initial() => const OrdersState(
    orders: [],
    isSearching: false,
    isLoading: false,
    isLoadingMore: false,
    hasMore: true,
  );

  final List<Order> orders;
  final bool isSearching;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final OrderStatus? selectedStatus;
  final String? searchQuery;
  final String? error;

  OrdersState copyWith({
    List<Order>? orders,
    bool? isSearching,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    OrderStatus? selectedStatus,
    String? searchQuery,
    String? error,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isSearching: isSearching ?? this.isSearching,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error ?? this.error,
    );
  }
}

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repo) : super(OrdersState.initial()) {
    scrollController = ScrollController()..addListener(_onScroll);
    _initSubscription();
    refresh(); // Initial fetch
  }

  final OrderRepository _repo;
  late final ScrollController scrollController;

  StreamSubscription<List<Order>>? _ordersSubscription;
  final _debouncer = Debouncer();

  bool _isLoadingMore = false;
  int _limit = 50;

  void _initSubscription() {
    _ordersSubscription?.cancel();
    _ordersSubscription = _repo.watchOrders(
      status: state.selectedStatus != null ? [state.selectedStatus!] : null,
      searchQuery: state.searchQuery,
      limit: _limit,
    ).listen((orders) {
      if (isClosed) return;

      int rank(OrderStatus s) {
        switch (s) {
          case OrderStatus.EN_ROUTE: return 0;
          case OrderStatus.ASSIGNED: return 1;
          case OrderStatus.UNASSIGNED: return 2;
          default: return 3;
        }
      }

      final sortedOrders = List<Order>.from(orders)
        ..sort((a, b) {
          final rankA = rank(a.status);
          final rankB = rank(b.status);
          if (rankA != rankB) return rankA.compareTo(rankB);
          return b.createdAt.compareTo(a.createdAt);
        });

      emit(state.copyWith(
        orders: sortedOrders,
        hasMore: orders.length >= _limit,
      ));
    });
  }

  Future<void> refresh() async {
    if (isClosed) return;
    _limit = 50;
    _initSubscription();
    emit(state.copyWith(isLoading: true, orders: []));

    final result = await _repo.getOrders(
      status: state.selectedStatus != null ? [state.selectedStatus!] : null,
      searchQuery: state.searchQuery,
      limit: _limit,
    );

    result.when(
      data: (_) => emit(state.copyWith(isLoading: false)),
      error: (e) => emit(state.copyWith(isLoading: false, error: e.message)),
    );
  }

  void filterByStatus(OrderStatus? status) {
    emit(state.copyWith(selectedStatus: status, orders: [], isLoading: true));
    refresh();
  }

  void searchOrders(String query) {
    emit(state.copyWith(isSearching: true));

    _debouncer.debounce(
      duration: const Duration(milliseconds: 500),
      onDebounce: () {
        if (isClosed) return;
        emit(state.copyWith(searchQuery: query, isSearching: false));
        refresh();
      },
    );
  }

  void loadMore() {
    if (_isLoadingMore || !state.hasMore) return;

    _isLoadingMore = true;
    _limit += 50;
    _initSubscription();
    
    _isLoadingMore = false;
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
