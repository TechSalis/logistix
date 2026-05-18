import 'dart:async';
import 'package:bootstrap/services/debouncer.dart';
import 'package:dispatcher/src/features/deliveries/domain/repositories/delivery_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class DeliveriesState {
  const DeliveriesState({
    required this.deliveries,
    required this.isSearching,
    required this.isLoading,
    required this.isLoadingMore,
    required this.hasMore,
    this.selectedStatus,
    this.searchQuery,
    this.error,
  });

  factory DeliveriesState.initial() => const DeliveriesState(
    deliveries: [],
    isSearching: false,
    isLoading: false,
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

  DeliveriesState copyWith({
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
    return DeliveriesState(
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

class DeliveriesCubit extends Cubit<DeliveriesState> {
  DeliveriesCubit(this._repo) : super(DeliveriesState.initial()) {
    scrollController = ScrollController()..addListener(_onScroll);
    _initSubscription();
    refresh(); // Initial fetch
  }

  final DeliveryRepository _repo;
  late final ScrollController scrollController;

  StreamSubscription<List<Delivery>>? _deliveriesSubscription;
  final _debouncer = Debouncer();

  bool _isLoadingMore = false;
  int _limit = 50;

  Future<void> _initSubscription() async {
    await _deliveriesSubscription?.cancel();
    _deliveriesSubscription = _repo.watchDeliveries(
      status: state.selectedStatus != null ? [state.selectedStatus!] : null,
      searchQuery: state.searchQuery,
      limit: _limit,
    ).listen((deliveries) {
      if (isClosed) return;

      int rank(DeliveryStatus s) {
        switch (s) {
          case DeliveryStatus.EN_ROUTE: return 0;
          case DeliveryStatus.ASSIGNED: return 1;
          case DeliveryStatus.PENDING: return 2;
          case DeliveryStatus.DELIVERED: return 3;
          case DeliveryStatus.CANCELLED: return 3;
        }
      }

      final sortedDeliveries = List<Delivery>.from(deliveries)
        ..sort((a, b) {
          final rankA = rank(a.status);
          final rankB = rank(b.status);
          if (rankA != rankB) return rankA.compareTo(rankB);
          return b.createdAt.compareTo(a.createdAt);
        });

      emit(state.copyWith(
        deliveries: sortedDeliveries,
        hasMore: deliveries.length >= _limit,
      ));
    });
  }

  Future<void> refresh() async {
    if (isClosed) return;
    _limit = 50;
    await _initSubscription();
    emit(state.copyWith(
      isLoading: true,
      deliveries: [],
      clearError: true,
      hasMore: true,
    ));

    final result = await _repo.getDeliveries(
      status: state.selectedStatus != null ? [state.selectedStatus!] : null,
      searchQuery: state.searchQuery,
      limit: _limit,
    );

    result.when(
      data: (_) => emit(state.copyWith(isLoading: false)),
      error: (e) => emit(state.copyWith(isLoading: false, error: e.message)),
    );
  }

  void filterByStatus(DeliveryStatus? status) {
    emit(state.copyWith(
      selectedStatus: status,
      clearStatus: status == null,
      deliveries: [],
      isLoading: true,
      clearError: true,
    ));
    refresh();
  }

  void searchDeliveries(String query) {
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
  Future<void> close() async {
    await _deliveriesSubscription?.cancel();
    scrollController.dispose();
    return super.close();
  }
}
