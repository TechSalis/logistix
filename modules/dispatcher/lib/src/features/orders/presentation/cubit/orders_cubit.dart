import 'dart:async';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/debouncer.dart';
import 'package:dispatcher/src/domain/repositories/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class OrdersState {
  OrdersState({
    required this.orders,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.selectedStatuses,
    required this.searchQuery,
    required this.error,
  });

  factory OrdersState.initial() => OrdersState(
    orders: [],
    isLoading: false,
    isLoadingMore: false,
    hasMore: true,
    selectedStatuses: [],
    searchQuery: null,
    error: null,
  );

  final List<Order> orders;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final List<String> selectedStatuses;
  final String? searchQuery;
  final String? error;

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    List<String>? selectedStatuses,
    String? searchQuery,
    String? error,
  }) => OrdersState(
    orders: orders ?? this.orders,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
    selectedStatuses: selectedStatuses ?? this.selectedStatuses,
    searchQuery: searchQuery ?? this.searchQuery,
    error: error,
  );
}

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit(this._repo) : super(OrdersState.initial()) {
    scrollController = ScrollController()..addListener(_onScroll);
  }

  final OrderRepository _repo;
  late final ScrollController scrollController;

  final _debouncer = Debouncer();

  static const int _pageSize = 20;

  Future<void> loadInitial() async {
    emit(state.copyWith(isLoading: true));
    await _loadPage(reset: true);
  }

  /// Handle order created events
  void handleOrderCreated(Order order) {
    final orders = [...state.orders];

    // Only add if it matches current filters
    if (state.searchQuery == null ||
        order.trackingNumber.contains(state.searchQuery!)) {
      orders.insert(0, order);
    }

    if (!isClosed) emit(state.copyWith(orders: orders));
  }

  /// Handle order updated events
  void handleOrderUpdated(Order order) {
    final orders = [...state.orders];
    final index = orders.indexWhere((o) => o.id == order.id);

    if (index != -1) {
      orders[index] = order;
    } else {
      // If not found, only add if it matches current filters
      if (state.searchQuery == null ||
          order.trackingNumber.contains(state.searchQuery!)) {
        orders.insert(0, order);
      }
    }

    if (!isClosed) emit(state.copyWith(orders: orders));
  }

  void filterByStatus(List<String> statuses) {
    emit(
      state.copyWith(
        selectedStatuses: statuses,
        orders: [],
        hasMore: true,
        isLoading: true,
      ),
    );
    _loadPage(reset: true);
  }

  void searchOrders(String query) {
    _debouncer.debounce(
      duration: const Duration(milliseconds: 500),
      onDebounce: () {
        if (isClosed) return;
        emit(
          state.copyWith(
            searchQuery: query,
            orders: [],
            hasMore: true,
            isLoading: true,
          ),
        );
        _loadPage(reset: true);
      },
    );
  }

  Future<void> _loadPage({bool reset = false}) async {
    if (state.isLoadingMore) return;

    final offset = reset ? 0 : state.orders.length;
    final result = await _repo.getOrders(
      status: state.selectedStatuses.isEmpty ? null : state.selectedStatuses,
      searchQuery: state.searchQuery,
      offset: offset,
    );

    result.map(
      (err) => emit(
        state.copyWith(
          isLoading: false,
          error: err is UserError ? err.message : 'Failed to load orders',
        ),
      ),
      (list) {
        final hasMore = list.length >= _pageSize;
        emit(
          state.copyWith(
            orders: reset ? list : [...state.orders, ...list],
            isLoading: false,
            isLoadingMore: false,
            hasMore: hasMore,
          ),
        );
      },
    );
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    const threshold = 200.0;
    final position = scrollController.position;
    if (position.maxScrollExtent - position.pixels <= threshold) {
      if (state.hasMore && !state.isLoadingMore) {
        emit(state.copyWith(isLoadingMore: true));
        _loadPage();
      }
    }
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    return super.close();
  }
}
