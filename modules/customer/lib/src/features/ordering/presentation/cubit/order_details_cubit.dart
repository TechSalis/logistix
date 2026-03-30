import 'dart:async';
import 'package:customer/src/domain/repositories/customer_order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'order_details_cubit.freezed.dart';

@freezed
abstract class OrderDetailsState with _$OrderDetailsState {
  const factory OrderDetailsState({
    required bool isLoading,
    Order? order,
    String? error,
  }) = _OrderDetailsState;

  factory OrderDetailsState.initial() => const OrderDetailsState(
    isLoading: false,
  );
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
