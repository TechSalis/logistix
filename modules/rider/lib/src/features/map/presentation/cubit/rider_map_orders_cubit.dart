import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

part 'rider_map_orders_cubit.freezed.dart';

@freezed
class RiderMapOrdersState with _$RiderMapOrdersState {
  const factory RiderMapOrdersState({
    required List<Order> orders,
    required bool isLoading,
    String? error,
  }) = _RiderMapOrdersState;

  factory RiderMapOrdersState.initial() =>
      const RiderMapOrdersState(orders: [], isLoading: false);
}

/// Cubit for displaying rider's active orders on the map
///
/// Subscribes to Drift stream for assigned/en-route orders
class RiderMapOrdersCubit extends Cubit<RiderMapOrdersState> {
  RiderMapOrdersCubit(this._repo) : super(RiderMapOrdersState.initial());
  final RiderRepository _repo;

  StreamSubscription<List<Order>>? _ordersSubscription;

  /// Initialize cubit with riderId (call after rider profile is loaded)
  void initialize() {
    _subscribeToOrders();
  }

  void _subscribeToOrders() {
    _ordersSubscription?.cancel();

    // Subscribe to assigned and en-route orders only (for map display)
    _ordersSubscription = _repo
        .watchRiderOrders(
          status: [OrderStatus.ASSIGNED, OrderStatus.EN_ROUTE],
          isPrioritySort: true, // Prioritize EN_ROUTE over ASSIGNED
        )
        .listen((orders) {
          if (!isClosed) {
            emit(state.copyWith(orders: orders));
          }
        });
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
