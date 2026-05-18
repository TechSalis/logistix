import 'dart:async';
import 'package:bootstrap/services/debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

class RiderDeliveriesState {
  const RiderDeliveriesState({
    required this.deliveries,
    required this.isSearching,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    this.selectedStatus,
    this.searchQuery,
    this.error,
  });

  factory RiderDeliveriesState.initial() => const RiderDeliveriesState(
    deliveries: [],
    isSearching: false,
    isLoading: true,
    isLoadingMore: false,
    hasMore: true,
  );

  final List<Delivery> deliveries;
  final bool isSearching;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final DeliveryStatus? selectedStatus;
  final String? searchQuery;
  final String? error;

  RiderDeliveriesState copyWith({
    List<Delivery>? deliveries,
    bool? isSearching,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    DeliveryStatus? selectedStatus,
    String? searchQuery,
    String? error,
    bool clearStatus = false,
    bool clearError = false,
  }) {
    return RiderDeliveriesState(
      deliveries: deliveries ?? this.deliveries,
      isSearching: isSearching ?? this.isSearching,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      selectedStatus:
          clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RiderDeliveriesCubit extends Cubit<RiderDeliveriesState> {
  RiderDeliveriesCubit(this._repo) : super(RiderDeliveriesState.initial()) {
    scrollController = ScrollController()..addListener(_onScroll);
  }
  late final ScrollController scrollController;

  final RiderRepository _repo;

  final _debouncer = Debouncer();

  StreamSubscription<List<Delivery>>? _deliveriesSubscription;

  // Pagination
  static const int _pageSize = 50;

  /// Initialize cubit with riderId (call after rider profile is loaded)
  void initialize() {
    emit(state.copyWith(isLoading: true, clearError: true));
    _subscribeToDeliveries();
  }

  int _loadedLimit = _pageSize;
  bool _isLoadingMore = false;

  void _subscribeToDeliveries() {
    _deliveriesSubscription?.cancel();

    // Use status enum directly
    final statuses = state.selectedStatus == null ? null : [state.selectedStatus!];

    // Priority sort for "All" tab to show active deliveries first
    final isPrioritySort = state.selectedStatus == null;

    // Subscribe to Drift stream - reactive to all changes
    // We watch from 0 up to current loaded limit to stay reactive
    _deliveriesSubscription = _repo
        .watchRiderDeliveries(
          status: statuses,
          searchQuery: state.searchQuery,
          limit: _loadedLimit,
          isPrioritySort: isPrioritySort,
        )
        .listen(
          (deliveries) {
            if (!isClosed) {
              final hasMore = deliveries.length >= _loadedLimit;
              emit(
                state.copyWith(
                  deliveries: deliveries,
                  hasMore: hasMore,
                  isLoading: false,
                  isLoadingMore: false, // Reset pagination loader
                  clearError: true,
                ),
              );
            }
          },
          onError: (e) {
            if (!isClosed) {
              emit(
                state.copyWith(
                  isLoading: false,
                  error: 'Failed to load deliveries',
                ),
              );
            }
          },
        );
  }

  void filterByStatus(DeliveryStatus? status) {
    _loadedLimit = _pageSize; // Reset pagination
    emit(
      state.copyWith(
        selectedStatus: status,
        deliveries: [], // Clear current deliveries to show shimmers
        isLoading: true, // Show loading state when switching tabs
        clearStatus: status == null,
        clearError: true,
      ),
    );
    _subscribeToDeliveries(); // Re-subscribe with new filters
  }

  void searchDeliveries(String query) {
    emit(
      state.copyWith(
        isSearching: true,
        isLoading: query.isNotEmpty,
        // Show loading during search if query not empty
        deliveries: query.isNotEmpty ? [] : state.deliveries,
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
            deliveries: query.isNotEmpty ? [] : state.deliveries,
          ),
        );
        _subscribeToDeliveries(); // Re-subscribe with search query
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
    _subscribeToDeliveries();

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
    _deliveriesSubscription?.cancel();
    scrollController.dispose();
    return super.close();
  }
}
