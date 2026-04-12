import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/domain/usecases/search_riders_usecase.dart';
import 'package:dispatcher/src/features/orders/data/dtos/order_create_input.dart';
import 'package:dispatcher/src/features/orders/domain/repositories/order_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class CreateOrderState {
  const CreateOrderState({
    required this.orders,
    this.riders = const [],
    this.isLoading = false,
    this.formKeyVersion = 0,
    this.error,
    this.success = false,
  });

  factory CreateOrderState.initial() =>
      const CreateOrderState(orders: [OrderCreateInput(dropOffAddress: '')]);

  final List<OrderCreateInput> orders;
  final List<Rider> riders;
  final bool isLoading;
  final int formKeyVersion;
  final String? error;
  final bool success;

  CreateOrderState copyWith({
    List<OrderCreateInput>? orders,
    List<Rider>? riders,
    bool? isLoading,
    int? formKeyVersion,
    String? error,
    bool? success,
  }) {
    return CreateOrderState(
      orders: orders ?? this.orders,
      riders: riders ?? this.riders,
      isLoading: isLoading ?? this.isLoading,
      formKeyVersion: formKeyVersion ?? this.formKeyVersion,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

class CreateOrderCubit extends Cubit<CreateOrderState> {
  CreateOrderCubit(this._orderRepo, this._searchRidersUseCase)
    : super(CreateOrderState.initial());

  final OrderRepository _orderRepo;
  final SearchRidersUseCase _searchRidersUseCase;

  Future<List<Rider>> searchRiders(
    String query, {
    double? lat,
    double? lng,
  }) async {
    final riders = await _searchRidersUseCase.call(query, lat: lat, lng: lng);
    emit(state.copyWith(riders: riders));
    return riders;
  }

  void addOrder() {
    emit(
      state.copyWith(
        orders: [
          ...state.orders,
          const OrderCreateInput(dropOffAddress: ''),
        ],
      ),
    );
  }

  void duplicateOrder(int index) {
    if (index < 0 || index >= state.orders.length) return;
    final orderToDuplicate = state.orders[index];
    final newList = List<OrderCreateInput>.from(state.orders)
      ..insert(index + 1, orderToDuplicate.copyWith());
    emit(state.copyWith(orders: newList));
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

  late final parseWithAi = AsyncRunner.withArg<String, AppError, void>((
    text,
  ) async {
    if (text.trim().isEmpty) return;
    final result = await _orderRepo.parseTextToOrders(text);
    if (isClosed) return;

    result.when(
      error: (err) => throw err, 
      data: (parsed) {
        emit(
          state.copyWith(
            orders: [
              ...state.orders.where((o) => o.dropOffAddress.isNotEmpty),
              ...parsed,
            ],
          ),
        );
      },
    );
  });

  Future<void> submitOrders() async {
    final validOrders = state.orders
        .where((o) => o.dropOffAddress.trim().isNotEmpty)
        .toList();

    if (validOrders.isEmpty) {
      emit(
        state.copyWith(error: 'Please add at least one valid delivery address'),
      );
      return;
    }

    emit(state.copyWith(isLoading: true));

    final result = await _orderRepo.createBulkOrders(validOrders);

    if (isClosed) return;

    result.when(
      error: (err) {
        emit(
          state.copyWith(
            isLoading: false,
            error: err.message ?? 'Failed to create orders',
          ),
        );
      }, 
      data: (list) => emit(state.copyWith(isLoading: false, success: true)),
    );
  }

  void reset() {
    emit(CreateOrderState.initial().copyWith(formKeyVersion: state.formKeyVersion + 1));
  }

  static const String _kOrderTemplate = '''
Dropoff: 
Dropoff Phone: 
---
Pickup: 
Pickup Phone: 
Amount: 
Description: 
''';

  Future<void> copyTemplateToClipboard() {
    return Clipboard.setData(const ClipboardData(text: _kOrderTemplate));
  }

  Future<String?> pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    return data?.text;
  }
}
