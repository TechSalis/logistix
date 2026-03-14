import 'dart:async';

import 'package:bootstrap/definitions/app_error.dart';
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

  Future<void> loadOrder(String orderId, {Order? initialOrder}) async {
    if (initialOrder != null) {
      emit(RiderOrderDetailsState.loaded(initialOrder));
    } else {
      emit(const RiderOrderDetailsState.loading());
    }

    final result = await _riderRepository.getOrder(orderId);

    if (isClosed) return;
    
    result.when(
      data: (order) => emit(RiderOrderDetailsState.loaded(order)),
      error: (error) => emit(
        RiderOrderDetailsState.error(
          error.message ?? 'Failed to load order tracking info',
        ),
      ),
    );
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
}
