import 'dart:async';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/extensions/result_extensions.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/features/orders/domain/repositories/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/shared.dart';

part 'order_details_state.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(this._orderRepository) : super(const OrderDetailsInitial());

  final OrderRepository _orderRepository;

  StreamSubscription<Order?>? _orderSubscription;

  late final callRunner = AsyncRunner.withArg<String?, UserError, void>(
    _launchCaller,
  );
  late final markDeliveredRunner = AsyncRunner<AppError, void>(_markDelivered);
  late final cancelRunner = AsyncRunner<AppError, void>(_cancelOrder);

  Future<void> _launchCaller(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    await LogistixLauncher.callNumber(phone);
  }

  void loadOrder(String id) {
    if (isClosed) return;
    emit(const OrderDetailsLoading());

    _orderSubscription?.cancel();
    _orderSubscription = _orderRepository.watchOrder(id).listen((order) {
      if (isClosed) return;

      if (order != null) {
        emit(OrderDetailsLoaded(order));
      } else if (state is! OrderDetailsLoaded) {
        emit(const OrderDetailsError('Order not found'));
      }
    });
  }

  Future<void> shareOrder(Order order) async {
    final trackingLink = LogistixTracking.generateLink(
      order.trackingNumber,
      trackingCode: order.trackingCode,
    );

    final trackingText =
        '📦 Order #${order.trackingNumber}\n'
        'Status: ${order.status.label}\n'
        '${order.description != null ? 'Description: ${order.description}\n' : ''}'
        'Drop-off: ${order.dropOffAddress}\n'
        '${order.pickupAddress != null ? 'Pickup: ${order.pickupAddress}\n' : ''}'
        '${order.dropOffPhone != null ? 'Contact: ${order.dropOffPhone}\n' : ''}'
        '${order.rider != null ? 'Rider: ${order.rider!.fullName}\n' : ''}'
        '${order.codAmount != null ? 'COD: \$${order.codAmount!.toStringAsFixed(2)}\n' : ''}'
        '${order.isPriority ? '⚡ Priority Order\n' : ''}'
        '\n🔗 Track: $trackingLink';

    await SharePlus.instance.share(
      ShareParams(
        text: trackingText,
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1),
      ),
    );
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }

  late final assignRunner = AsyncRunner.withArg<Rider, AppError, void>(
    _assignRider,
  );
  late final unassignRunner = AsyncRunner<AppError, void>(_unassignRider);

  Future<void> _assignRider(Rider rider) async {
    final currentState = state;
    if (currentState is! OrderDetailsLoaded || isClosed) return;

    final orderId = currentState.order.id;
    final result = await _orderRepository.assignRider(orderId, rider);
    result.throwOrReturn();
  }

  Future<void> _unassignRider() async {
    final currentState = state;
    if (currentState is! OrderDetailsLoaded || isClosed) return;

    final orderId = currentState.order.id;
    final result = await _orderRepository.unassignRider(orderId);
    result.throwOrReturn();
  }

  Future<void> _markDelivered() async {
    final currentState = state;
    if (currentState is! OrderDetailsLoaded || isClosed) return;

    final orderId = currentState.order.id;
    final result = await _orderRepository.updateOrderStatus(
      orderId,
      OrderStatus.DELIVERED,
    );
    result.throwOrReturn();
  }

  late final rejectRunner = AsyncRunner<AppError, void>(_rejectOrder);

  Future<void> _rejectOrder() async {
    final currentState = state;
    if (currentState is! OrderDetailsLoaded || isClosed) return;

    final orderId = currentState.order.id;
    final result = await _orderRepository.rejectOrder(orderId);
    result.throwOrReturn();
  }

  Future<void> _cancelOrder() async {
    final currentState = state;
    if (currentState is! OrderDetailsLoaded || isClosed) return;

    final orderId = currentState.order.id;
    final result = await _orderRepository.cancelOrder(orderId);
    result.throwOrReturn();
  }

  Future<void> openMap(double lat, double lng) {
    return LogistixLauncher.openMap(lat, lng);
  }
}
