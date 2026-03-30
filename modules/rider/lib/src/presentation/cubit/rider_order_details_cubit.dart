import 'dart:async';

import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rider/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

part 'rider_order_details_cubit.freezed.dart';

@freezed
class RiderOrderDetailsState with _$RiderOrderDetailsState {
  const factory RiderOrderDetailsState.initial() = _Initial;
  const factory RiderOrderDetailsState.loading() = _Loading;
  const factory RiderOrderDetailsState.loaded(Order order) = _Loaded;
  const factory RiderOrderDetailsState.error(String message) = _Error;
}

class RiderOrderDetailsCubit extends Cubit<RiderOrderDetailsState> {
  RiderOrderDetailsCubit(this._riderRepository)
    : super(const RiderOrderDetailsState.initial());

  final RiderRepository _riderRepository;
  
  StreamSubscription<Order?>? _orderSubscription;

  late final unassignRunner = AsyncRunner<AppError, void>(_unassignOrder);
  late final markDeliveredRunner = AsyncRunner<AppError, void>(_markDelivered);
  late final startDeliveryRunner = AsyncRunner<AppError, void>(_startDelivery);

  Future<void> _startDelivery() async {
    await state.mapOrNull(
      loaded: (state) async {
        final result = await _riderRepository.updateOrderStatus(
          state.order.id,
          OrderStatus.EN_ROUTE,
        );

        result.when(
          error: (error) {
            throw UserError(
              message: error.message ?? 'Failed to start delivery',
            );
          },
        );
      },
    );
  }

  void loadOrder(String orderId, {Order? initialOrder}) {
    if (initialOrder != null) {
      emit(RiderOrderDetailsState.loaded(initialOrder));
    } else {
      emit(const RiderOrderDetailsState.loading());
    }

    // Subscribe to order stream from Drift
    _orderSubscription?.cancel();
    _orderSubscription = _riderRepository
        .watchOrder(orderId)
        .listen(
          (order) {
            if (isClosed) return;

            if (order != null) {
              emit(RiderOrderDetailsState.loaded(order));
            } else if (state is! _Loaded) {
              emit(const RiderOrderDetailsState.error('Order not found'));
            }
          },
          onError: (Object error) {
            if (isClosed) return;
            emit(
              RiderOrderDetailsState.error(
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
    await state.mapOrNull(
      loaded: (state) async {
        final result = await _riderRepository.updateOrderStatus(
          state.order.id,
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
      },
    );
  }

  Future<void> _unassignOrder() async {
    await state.mapOrNull(
      loaded: (state) async {
        final result = await _riderRepository.updateOrderStatus(
          state.order.id,
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
      },
    );
  }

  Future<void> _markDelivered() async {
    await state.mapOrNull(
      loaded: (state) async {
        final result = await _riderRepository.updateOrderStatus(
          state.order.id,
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
      },
    );
  }

  Future<void> openMap(double lat, double lng) async {
    await LauncherUtils.openMap(lat, lng);
  }
}
