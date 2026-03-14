import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/domain/repositories/order_repository.dart';
import 'package:dispatcher/src/domain/repositories/rider_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class CreateOrderState {
  CreateOrderState({
    required this.orders,
    required this.isLoading,
    this.riders = const [],
    this.error,
    this.success = false,
  });

  factory CreateOrderState.initial() => CreateOrderState(
    orders: [const OrderCreateInput(pickupAddress: '')],
    isLoading: false,
  );

  final List<OrderCreateInput> orders;
  final List<Rider> riders;
  final bool isLoading;
  final String? error;
  final bool success;

  CreateOrderState copyWith({
    List<OrderCreateInput>? orders,
    List<Rider>? riders,
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return CreateOrderState(
      orders: orders ?? this.orders,
      riders: riders ?? this.riders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      success: success ?? this.success,
    );
  }
}

class CreateOrderCubit extends Cubit<CreateOrderState> {
  CreateOrderCubit(this._orderRepo, this._riderRepo)
    : super(CreateOrderState.initial());

  final OrderRepository _orderRepo;
  final RiderRepository _riderRepo;

  Future<List<Rider>> searchRiders(String query) async {
    final result = await _riderRepo.getRiders(search: query, limit: 20);
    return result.map((err) => [], (list) => list);
  }

  void addOrder() {
    emit(
      state.copyWith(
        orders: [
          ...state.orders,
          const OrderCreateInput(pickupAddress: ''),
        ],
      ),
    );
  }

  void removeOrder(int index) {
    if (state.orders.isEmpty) return;
    final newList = List<OrderCreateInput>.from(state.orders)..removeAt(index);
    emit(state.copyWith(orders: newList));
  }

  void updateOrder(int index, OrderCreateInput order) {
    final newList = List<OrderCreateInput>.from(state.orders)..[index] = order;
    emit(state.copyWith(orders: newList));
  }

  late final parseWithAi = AsyncRunner.withArg<String, AppError, void>(
    _parseWithAI,
  );

  Future<void> _parseWithAI(String text) async {
    if (text.trim().isEmpty) return;

    final result = await _orderRepo.parseTextToOrders(text);
    if (isClosed) return;

    result.when(
      data: (parsed) {
        emit(
          state.copyWith(
            orders: [
              ...state.orders.where((o) => o.pickupAddress.isNotEmpty),
              ...parsed,
            ],
          ),
        );
      },
      error: (err) => throw err,
    );
  }

  Future<void> submit() async {
    final validOrders = state.orders
        .where((o) => o.pickupAddress.trim().isNotEmpty)
        .toList();

    if (validOrders.isEmpty) {
      emit(
        state.copyWith(error: 'Please add at least one valid pickup address'),
      );
      return;
    }

    emit(state.copyWith(isLoading: true));

    final result = await _orderRepo.createBulkOrders(validOrders);
    if (isClosed) return;
    result.map(
      (err) => emit(
        state.copyWith(
          isLoading: false,
          error: err is UserError ? err.message : 'Failed to create orders',
        ),
      ),
      (list) => emit(state.copyWith(isLoading: false, success: true)),
    );
  }

  void reset() {
    emit(CreateOrderState.initial());
  }
}
