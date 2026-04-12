import 'dart:async';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

abstract class RiderOrderDetailsState {
  const RiderOrderDetailsState();

  const factory RiderOrderDetailsState.initial() = RiderOrderDetailsInitial;
  const factory RiderOrderDetailsState.loading() = RiderOrderDetailsLoading;
  const factory RiderOrderDetailsState.loaded(Order order) = RiderOrderDetailsLoaded;
  const factory RiderOrderDetailsState.error(String message) = RiderOrderDetailsError;
}

class RiderOrderDetailsInitial extends RiderOrderDetailsState {
  const RiderOrderDetailsInitial();
}

class RiderOrderDetailsLoading extends RiderOrderDetailsState {
  const RiderOrderDetailsLoading();
}

class RiderOrderDetailsLoaded extends RiderOrderDetailsState {
  const RiderOrderDetailsLoaded(this.order);
  final Order order;
}

class RiderOrderDetailsError extends RiderOrderDetailsState {
  const RiderOrderDetailsError(this.message);
  final String message;
}

class RiderOrderDetailsCubit extends Cubit<RiderOrderDetailsState> {
  RiderOrderDetailsCubit(this._riderRepository)
    : super(const RiderOrderDetailsInitial());

  final RiderRepository _riderRepository;
  
  StreamSubscription<Order?>? _orderSubscription;

  late final unassignRunner = AsyncRunner<AppError, void>(_unassignOrder);
  late final markDeliveredRunner = AsyncRunner<AppError, void>(_markDelivered);
  late final startDeliveryRunner = AsyncRunner<AppError, void>(_startDelivery);

  Future<void> _startDelivery() async {
    final curState = state;
    if (curState is RiderOrderDetailsLoaded) {
      final result = await _riderRepository.updateOrderStatus(
        curState.order.id,
        OrderStatus.EN_ROUTE,
      );

      result.when(
        error: (error) {
          throw UserError(
            message: error.message ?? 'Failed to start delivery',
          );
        },
      );
    }
  }

  void loadOrder(String orderId, {Order? initialOrder}) {
    if (initialOrder != null) {
      emit(RiderOrderDetailsLoaded(initialOrder));
    } else {
      emit(const RiderOrderDetailsLoading());
    }

    // Subscribe to order stream from Drift
    _orderSubscription?.cancel();
    _orderSubscription = _riderRepository
        .watchOrder(orderId)
        .listen(
          (order) {
            if (isClosed) return;

            if (order != null) {
              emit(RiderOrderDetailsLoaded(order));
            } else if (state is! RiderOrderDetailsLoaded) {
              emit(const RiderOrderDetailsError('Order not found'));
            }
          },
          onError: (Object error) {
            if (isClosed) return;
            emit(
              RiderOrderDetailsError(
                (error is UserError ? error.message : null) ??
                    'Failed to load order tracking info',
              ),
            );
          },
        );
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }

  Future<void> updateStatus(OrderStatus status) async {
    final curState = state;
    if (curState is RiderOrderDetailsLoaded) {
      final result = await _riderRepository.updateOrderStatus(
        curState.order.id,
        status,
      );

      if (isClosed) return;

      result.when(
        error: (error) {
          throw UserError(
            message: error.message ?? 'Failed to update order status',
          );
        },
      );
    }
  }

  Future<void> _unassignOrder() async {
    final curState = state;
    if (curState is RiderOrderDetailsLoaded) {
      final result = await _riderRepository.updateOrderStatus(
        curState.order.id,
        OrderStatus.UNASSIGNED,
      );

      if (isClosed) return;

      result.when(
        error: (error) {
          throw UserError(
            message: error.message ?? 'Failed to unassign order',
          );
        },
      );
    }
  }

  Future<void> _markDelivered() async {
    final curState = state;
    if (curState is RiderOrderDetailsLoaded) {
      final result = await _riderRepository.updateOrderStatus(
        curState.order.id,
        OrderStatus.DELIVERED,
      );

      if (isClosed) return;

      result.when(
        error: (error) {
          throw UserError(
            message: error.message ?? 'Failed to mark order as delivered',
          );
        },
      );
    }
  }

  Future<void> openMap(double lat, double lng) async {
    await LogistixLauncher.openMap(lat, lng);
  }
}
