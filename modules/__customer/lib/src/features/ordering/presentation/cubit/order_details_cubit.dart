import 'dart:async';

import 'package:customer/src/domain/repositories/customer_order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class OrderDetailsState {
  const OrderDetailsState({
    required this.isLoading,
    this.order,
    this.error,
  });

  factory OrderDetailsState.initial() => const OrderDetailsState(
    isLoading: false,
  );

  final bool isLoading;
  final Order? order;
  final String? error;

  OrderDetailsState copyWith({
    bool? isLoading,
    Order? order,
    String? error,
  }) {
    return OrderDetailsState(
      isLoading: isLoading ?? this.isLoading,
      order: order ?? this.order,
      error: error ?? this.error,
    );
  }
}

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(this._repo, this._orderId) : super(OrderDetailsState.initial()) {
    _subscribeToOrder();
  }

  final CustomerOrderRepository _repo;
  final String _orderId;
  StreamSubscription<Order?>? _subscription;

  void _subscribeToOrder() {
    _subscription?.cancel();
    _subscription = _repo.watchOrder(_orderId).listen((order) {
      if (order != null) {
        emit(state.copyWith(order: order, isLoading: false));
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
