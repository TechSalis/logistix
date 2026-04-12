import 'package:customer/src/data/dtos/customer_order_input.dart';
import 'package:customer/src/domain/repositories/customer_order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class OrderFormState {
  const OrderFormState({
    required this.isLoading,
    this.createdOrder,
    this.error,
    this.success = false,
  });

  factory OrderFormState.initial() => const OrderFormState(
    isLoading: false,
  );

  final bool isLoading;
  final Order? createdOrder;
  final String? error;
  final bool success;

  OrderFormState copyWith({
    bool? isLoading,
    Order? createdOrder,
    String? error,
    bool? success,
  }) {
    return OrderFormState(
      isLoading: isLoading ?? this.isLoading,
      createdOrder: createdOrder ?? this.createdOrder,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

class OrderFormCubit extends Cubit<OrderFormState> {
  OrderFormCubit(this._repo) : super(OrderFormState.initial());

  final CustomerOrderRepository _repo;

  Future<void> submitOrder(CustomerOrderInput input) async {
    emit(state.copyWith(isLoading: true, success: false));
    
    final result = await _repo.createOrder(input);

    if (isClosed) return;

    result.when(
      error: (err) => emit(state.copyWith(isLoading: false, error: err.message)),
      data: (order) => emit(state.copyWith(isLoading: false, success: true, createdOrder: order)),
    );
  }

  void reset() => emit(OrderFormState.initial());
}
