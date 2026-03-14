import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/domain/repositories/order_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

part 'order_details_state.dart';
part 'order_details_cubit.freezed.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(this._orderRepository)
    : super(const OrderDetailsState.initial());

  final OrderRepository _orderRepository;

  late final callRunner = AsyncRunner.withArg<String?, AppError, void>(
    _launchCaller,
  );

  Future<void> _launchCaller(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> loadOrder(String id) async {
    if (isClosed) return;
    emit(const OrderDetailsState.loading());
    final result = await _orderRepository.getOrder(id);
    if (isClosed) return;
    result.when(
      data: (order) => emit(OrderDetailsState.loaded(order)),
      error: (error) => emit(
        OrderDetailsState.error(error.message ?? 'Failed to load order'),
      ),
    );
  }

  Future<void> updateStatus(OrderStatus status) async {
    final currentState = state;
    if (currentState is! _Loaded || isClosed) return;

    final orderId = currentState.order.id;
    final result = await _orderRepository.updateOrderStatus(orderId, status);
    if (isClosed) return;

    result.when(
      data: (_) => loadOrder(orderId),
      error: (error) => emit(
        OrderDetailsState.error(
          error.message ?? 'Failed to update order status',
        ),
      ),
    );
  }

  Future<void> assignRider(String riderId) async {
    final currentState = state;
    if (currentState is! _Loaded || isClosed) return;

    final orderId = currentState.order.id;
    final result = await _orderRepository.assignRider(orderId, riderId);
    if (isClosed) return;

    result.when(
      data: (_) => loadOrder(orderId),
      error: (error) => emit(
        OrderDetailsState.error(error.message ?? 'Failed to assign rider'),
      ),
    );
  }

  Future<void> cancelOrder() async {
    final currentState = state;
    if (currentState is! _Loaded || isClosed) return;

    final orderId = currentState.order.id;
    final result = await _orderRepository.cancelOrder(orderId);
    if (isClosed) return;

    result.when(
      data: (_) => loadOrder(orderId),
      error: (error) => emit(
        OrderDetailsState.error(error.message ?? 'Failed to cancel order'),
      ),
    );
  }
}
