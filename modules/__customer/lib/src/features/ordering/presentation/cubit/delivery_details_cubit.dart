import 'dart:async';

import 'package:customer/src/domain/repositories/customer_delivery_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class DeliveryDetailsState {
  const DeliveryDetailsState({
    required this.isLoading,
    this.delivery,
    this.error,
  });

  factory DeliveryDetailsState.initial() => const DeliveryDetailsState(
    isLoading: false,
  );

  final bool isLoading;
  final Delivery? delivery;
  final String? error;

  DeliveryDetailsState copyWith({
    bool? isLoading,
    Delivery? delivery,
    String? error,
  }) {
    return DeliveryDetailsState(
      isLoading: isLoading ?? this.isLoading,
      delivery: delivery ?? this.delivery,
      error: error ?? this.error,
    );
  }
}

class DeliveryDetailsCubit extends Cubit<DeliveryDetailsState> {
  DeliveryDetailsCubit(this._repo, this._deliveryId) : super(DeliveryDetailsState.initial()) {
    _subscribeToDelivery();
  }

  final CustomerDeliveryRepository _repo;
  final String _deliveryId;
  StreamSubscription<Delivery?>? _subscription;

  void _subscribeToDelivery() {
    _subscription?.cancel();
    _subscription = _repo.watchDelivery(_deliveryId).listen((delivery) {
      if (delivery != null) {
        emit(state.copyWith(delivery: delivery, isLoading: false));
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
