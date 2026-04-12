import 'dart:async';
import 'package:bootstrap/services/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

class RiderOrdersState {
  const RiderOrdersState({
    required this.orders,
    required this.isSearching,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    this.selectedStatus,
    this.searchQuery,
    this.error,
  });

  factory RiderOrdersState.initial() => const RiderOrdersState(
    orders: [],
    isSearching: false,
    isLoading: true,
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

  RiderOrdersState copyWith({
    List<Order>? orders,
    bool? isSearching,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    OrderStatus? selectedStatus,
    String? searchQuery,
    String? error,
    bool clearStatus = false,
  }) {
    return RiderOrdersState(
      orders: orders ?? this.orders,
      isSearching: isSearching ?? this.isSearching,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      error: error ?? this.error,
    );
  }
}

class RiderOrdersCubit extends Cubit<RiderOrdersState> {
  RiderOrdersCubit(this._repo) : super(RiderOrdersState.initial()) {
    scrollController = ScrollController()..addListener(_onScroll);
  }
  late final ScrollController scrollController;

  final RiderRepository _repo;

  final _debouncer = Debouncer();

  StreamSubscription<List<Order>>? _ordersSubscription;

  // Pagination
  static const int _pageSize = 50;

  /// Initialize cubit with riderId (call after rider profile is loaded)
  void initialize() {
    emit(state.copyWith(isLoading: true));
    _subscribeToOrders();
  }

  int _loadedLimit = _pageSize;
  bool _isLoadingMore = false;

  void _subscribeToOrders() {
    _ordersSubscription?.cancel();

    // Use status enum directly
    final statuses = state.selectedStatus == null
        ? null
        : [state.selectedStatus!];

    // Priority sort for "All" tab to show active orders first
    final isPrioritySort = state.selectedStatus == null;

    // Subscribe to Drift stream - reactive to all changes
    // We watch from 0 up to current loaded limit to stay reactive
    _ordersSubscription = _repo
        .watchRiderOrders(
          status: statuses,
          searchQuery: state.searchQuery,
          limit: _loadedLimit,
          isPrioritySort: isPrioritySort,
        )
        .listen(
          (orders) {
            if (!isClosed) {
              final hasMore = orders.length >= _loadedLimit;
              emit(
                state.copyWith(
                  orders: orders,
                  hasMore: hasMore,
                  isLoading: false,
                  isLoadingMore: false, // Reset pagination loader
                ),
              );
            }
          },
          onError: (e) {
            if (!isClosed) {
              emit(
                state.copyWith(
                  isLoading: false,
                  error: 'Failed to load orders',
                ),
              );
            }
          },
        );
  }

  void filterByStatus(OrderStatus? status) {
    _loadedLimit = _pageSize; // Reset pagination
    emit(
      state.copyWith(
        selectedStatus: status,
        orders: [], // Clear current orders to show shimmers
        isLoading: true, // Show loading state when switching tabs
        clearStatus: status == null,
      ),
    );
    _subscribeToOrders(); // Re-subscribe with new filters
  }

  void searchOrders(String query) {
    emit(
      state.copyWith(
        isSearching: true,
        isLoading: query.isNotEmpty,
        // Show loading during search if query not empty
        orders: query.isNotEmpty ? [] : state.orders,
      ),
    );

    _debouncer.debounce(
      duration: const Duration(milliseconds: 500),
      onDebounce: () {
        if (isClosed) return;
        _loadedLimit = _pageSize; // Reset pagination on search
        emit(
          state.copyWith(
            searchQuery: query,
            isSearching: false,
            orders: query.isNotEmpty ? [] : state.orders,
          ),
        );
        _subscribeToOrders(); // Re-subscribe with search query
      },
    );
  }

  void loadMore() {
    if (_isLoadingMore || state.isLoadingMore || !state.hasMore) {
      return;
    }

    _isLoadingMore = true;
    _loadedLimit += _pageSize;

    emit(state.copyWith(isLoadingMore: true));

    // Just re-subscribe with larger limit.
    // Reactive stream will emit new list with more items.
    _subscribeToOrders();

    // Reset loading state local flag immediately
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
