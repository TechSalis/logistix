import '../../../../data/dtos/customer_order_input.dart';
import '../../../../domain/repositories/customer_order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'order_form_cubit.freezed.dart';

@freezed
abstract class OrderFormState with _$OrderFormState {
  const factory OrderFormState({
    required bool isLoading,
    Order? createdOrder,
    String? error,
    @Default(false) bool success,
  }) = _OrderFormState;

  factory OrderFormState.initial() => const OrderFormState(
    isLoading: false,
  );
}

class OrderFormCubit extends Cubit<OrderFormState> {
  OrderFormCubit(this._repo) : super(OrderFormState.initial());

  final CustomerOrderRepository _repo;

  Future<void> submitOrder(CustomerOrderInput input) async {
    emit(state.copyWith(isLoading: true, error: null, success: false));
    
    final result = await _repo.createOrder(input);

    if (isClosed) return;

    result.map(
      (err) => emit(state.copyWith(isLoading: false, error: err.message)),
      (order) => emit(state.copyWith(isLoading: false, success: true, createdOrder: order)),
    );
  }

  void reset() => emit(OrderFormState.initial());
}
