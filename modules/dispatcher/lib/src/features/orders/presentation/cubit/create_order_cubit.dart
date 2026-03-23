import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/data/dtos/order_create_input.dart';
import 'package:dispatcher/src/domain/repositories/order_repository.dart';
import 'package:dispatcher/src/domain/usecases/search_riders_usecase.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'create_order_cubit.freezed.dart';

@freezed
class CreateOrderState with _$CreateOrderState {
  const factory CreateOrderState({
    required List<OrderCreateInput> orders,
    @Default([]) List<Rider> riders,
    @Default(false) bool isLoading,
    @Default(0) int formKeyVersion,
    String? error,
    @Default(false) bool success,
  }) = _CreateOrderState;

  factory CreateOrderState.initial() =>
      const CreateOrderState(orders: [OrderCreateInput(dropOffAddress: '')]);
}

class CreateOrderCubit extends Cubit<CreateOrderState> {
  CreateOrderCubit(this._orderRepo, this._searchRidersUseCase)
    : super(CreateOrderState.initial());

  final OrderRepository _orderRepo;
  final SearchRidersUseCase _searchRidersUseCase;

  Future<List<Rider>> searchRiders(String query) async {
    final riders = await _searchRidersUseCase(query);
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

    result.map((err) => throw err, (parsed) {
      emit(
        state.copyWith(
          orders: [
            ...state.orders.where((o) => o.dropOffAddress.isNotEmpty),
            ...parsed,
          ],
        ),
      );
    });
  });

  Future<void> submitOrders() async {
    final validOrders = state.orders
        .where((o) => o.dropOffAddress.trim().isNotEmpty)
        .toList();

    if (validOrders.isEmpty) {
      emit(
        state.copyWith(error: 'Please add at least one valid delivery address'),
      );
      // Reset error after a delay if needed, or handle in UI
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    final result = await _orderRepo.createBulkOrders(validOrders);

    if (isClosed) return;

    result.map((err) {
      emit(
        state.copyWith(
          isLoading: false,
          error: err is UserError ? err.message : 'Failed to create orders',
        ),
      );
    }, (list) => emit(state.copyWith(isLoading: false, success: true)));
  }

  void reset() {
    emit(CreateOrderState.initial().copyWith(formKeyVersion: state.formKeyVersion + 1));
  }

  // Clean structured key-value template (two example orders separated by ---)
  static const String _kOrderTemplate = '''
Pickup: 12 Ada George Road, GRA
Pickup Phone: 08012345678
Dropoff: Rumuokoro Junction, PH
Dropoff Phone: 07098765432
Amount: 5000
Description: 2 Large Pizzas
''';

  Future<void> copyTemplateToClipboard() {
    return Clipboard.setData(const ClipboardData(text: _kOrderTemplate));
  }

  Future<String?> pasteFromClipboard() async {
    final data = await Clipboard.getData('text/plain');
    return data?.text;
  }
}
