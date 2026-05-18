import 'package:customer/src/data/dtos/customer_delivery_input.dart';
import 'package:customer/src/domain/repositories/customer_delivery_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class DeliveryFormState {
  const DeliveryFormState({
    required this.isLoading,
    this.createdDelivery,
    this.error,
    this.success = false,
  });

  factory DeliveryFormState.initial() => const DeliveryFormState(
    isLoading: false,
  );

  final bool isLoading;
  final Delivery? createdDelivery;
  final String? error;
  final bool success;

  DeliveryFormState copyWith({
    bool? isLoading,
    Delivery? createdDelivery,
    String? error,
    bool? success,
  }) {
    return DeliveryFormState(
      isLoading: isLoading ?? this.isLoading,
      createdDelivery: createdDelivery ?? this.createdDelivery,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

class DeliveryFormCubit extends Cubit<DeliveryFormState> {
  DeliveryFormCubit(this._repo) : super(DeliveryFormState.initial());

  final CustomerDeliveryRepository _repo;

  Future<void> submitDelivery(CustomerDeliveryInput input) async {
    emit(state.copyWith(isLoading: true, success: false));
    
    final result = await _repo.createDelivery(input);

    if (isClosed) return;

    result.when(
      error: (err) => emit(state.copyWith(isLoading: false, error: err.message)),
      data: (delivery) => emit(state.copyWith(isLoading: false, success: true, createdDelivery: delivery)),
    );
  }

  void reset() => emit(DeliveryFormState.initial());
}
