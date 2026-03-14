import 'dart:async';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

class RiderOrdersState {
  const RiderOrdersState({
    required this.orders,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    required this.selectedStatuses,
    required this.error,
    required this.metricsError,
    required this.metrics,
    required this.isLoadingMetrics,
  });

  factory RiderOrdersState.initial() => const RiderOrdersState(
    orders: [],
    isLoading: false,
    isLoadingMore: false,
    hasMore: true,
    selectedStatuses: [],
    error: null,
    metricsError: null,
    metrics: null,
    isLoadingMetrics: false,
  );

  final List<Order> orders;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final List<OrderStatus> selectedStatuses;
  final String? error;
  final String? metricsError;
  final RiderMetrics? metrics;
  final bool isLoadingMetrics;

  RiderOrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    List<OrderStatus>? selectedStatuses,
    String? error,
    String? metricsError,
    RiderMetrics? metrics,
    bool? isLoadingMetrics,
  }) => RiderOrdersState(
    orders: orders ?? this.orders,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
    selectedStatuses: selectedStatuses ?? this.selectedStatuses,
    metricsError: metricsError,
    error: error,
    metrics: metrics ?? this.metrics,
    isLoadingMetrics: isLoadingMetrics ?? this.isLoadingMetrics,
  );
}

class RiderOrdersCubit extends Cubit<RiderOrdersState> {
  RiderOrdersCubit(this._repo) : super(RiderOrdersState.initial()) {
    scrollController = ScrollController()..addListener(_onScroll);
  }

  final RiderRepository _repo;

  late final ScrollController scrollController;

  static const int _pageSize = 20;

  void loadInitial() {
    emit(
      state.copyWith(
        selectedStatuses: [OrderStatus.assigned, OrderStatus.enRoute],
        isLoading: true,
      ),
    );
    _loadPage(reset: true);
    loadMetrics();
  }

  Future<void> loadMetrics() async {
    emit(state.copyWith(isLoadingMetrics: true));

    final result = await _repo.getRiderMetrics();

    if (isClosed) return;

    result.map(
      (err) => emit(
        state.copyWith(
          isLoadingMetrics: false,
          metricsError: err is UserError
              ? err.message
              : 'Failed to load metrics',
        ),
      ),
      (metrics) {
        emit(state.copyWith(metrics: metrics, isLoadingMetrics: false));
      },
    );
  }

  /// Handle order updates from RiderBloc
  void handleOrderUpdate(Order order) {
    final orders = [...state.orders];
    final index = orders.indexWhere((o) => o.id == order.id);

    if (index != -1) {
      orders[index] = order;
    } else {
      // Only add new orders if they match the current filter
      if (state.selectedStatuses.isEmpty ||
          state.selectedStatuses.contains(order.status)) {
        orders.insert(0, order);
      }
    }

    emit(state.copyWith(orders: orders));
  }

  /// Handle metrics updates from RiderBloc
  void handleMetricsUpdate(RiderMetrics metrics) {
    emit(state.copyWith(metrics: metrics, isLoadingMetrics: false));
  }

  void filterByStatus(List<OrderStatus> statuses) {
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

  Future<void> _loadPage({bool reset = false}) async {
    if (state.isLoadingMore) return;

    final offset = reset ? 0 : state.orders.length;
    final status = state.selectedStatuses.isEmpty
        ? null
        : state.selectedStatuses;

    // Determine sort order based on selected statuses
    // History orders (delivered, cancelled) = asc
    // Assigned orders (assigned, enroute) = desc
    final sortOrder = _getSortOrder(status);

    final result = await _repo.getRiderOrders(
      status: status,
      limit: _pageSize,
      offset: offset,
      sortOrder: sortOrder,
    );

    if (isClosed) return;

    result.map(
      (err) => emit(
        state.copyWith(
          isLoading: false,
          isLoadingMore: false,
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

  String _getSortOrder(List<OrderStatus>? statuses) {
    if (statuses == null || statuses.isEmpty) return 'desc';

    // If filtering by history statuses (delivered, cancelled), use asc
    final historyStatuses = {OrderStatus.delivered, OrderStatus.cancelled};
    final isHistoryView = statuses.every(historyStatuses.contains);

    return isHistoryView ? 'asc' : 'desc';
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

  Future<void> cancelOrder(String orderId) async {
    final result = await _repo.updateOrderStatus(
      orderId,
      OrderStatus.cancelled,
    );

    if (isClosed) return;

    result.when(
      data: (_) {
        // Clear error on success and refresh orders
        emit(state.copyWith());
        _loadPage(reset: true);
      },
      error: (err) {
        emit(
          state.copyWith(
            error: err.message ?? 'Failed to cancel order',
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    scrollController.dispose();
    return super.close();
  }
}
