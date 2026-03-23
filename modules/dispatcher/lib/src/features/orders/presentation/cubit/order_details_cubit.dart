import 'dart:async';
import 'package:bootstrap/definitions/app_error.dart';
import 'package:bootstrap/extensions/result_extensions.dart';
import 'package:bootstrap/services/async_runner/async_runner.dart';
import 'package:dispatcher/src/domain/repositories/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

part 'order_details_state.dart';
part 'order_details_cubit.freezed.dart';

class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  OrderDetailsCubit(this._orderRepository)
    : super(const OrderDetailsState.initial());

  final OrderRepository _orderRepository;

  StreamSubscription<Order?>? _orderSubscription;

  late final callRunner = AsyncRunner.withArg<String?, UserError, void>(
    _launchCaller,
  );
  late final markDeliveredRunner = AsyncRunner<AppError, void>(_markDelivered);
  late final cancelRunner = AsyncRunner<AppError, void>(_cancelOrder);

  Future<void> _launchCaller(String? phone) async {
    if (phone == null || phone.isEmpty) return;

    final url = Uri.parse('tel:$phone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void loadOrder(String id) {
    if (isClosed) return;
    emit(const OrderDetailsState.loading());

    _orderSubscription?.cancel();
    _orderSubscription = _orderRepository.watchOrder(id).listen((order) {
      if (isClosed) return;
      if (order != null) {
        emit(OrderDetailsState.loaded(order));
      } else if (state is! _Loaded) {
        emit(const OrderDetailsState.error('Order not found'));
      }
    });
  }

  Future<void> shareOrder(Order order) async {
    final trackingText =
        'Track Your Order: #${order.trackingNumber}\n'
        'Link: ${EnvConfig.trackingLink}/${order.trackingNumber}';

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
    if (currentState is! _Loaded || isClosed) return;

    final orderId = currentState.order.id;
    final result = await _orderRepository.assignRider(orderId, rider);
    result.throwOrReturn();
  }

  Future<void> _unassignRider() async {
    final currentState = state;
    if (currentState is! _Loaded || isClosed) return;

    final orderId = currentState.order.id;
    final result = await _orderRepository.unassignRider(orderId);
    result.throwOrReturn();
  }

  Future<void> _markDelivered() async {
    final currentState = state;
    if (currentState is! _Loaded || isClosed) return;

    final orderId = currentState.order.id;
    final result = await _orderRepository.updateOrderStatus(
      orderId,
      OrderStatus.delivered,
    );
    result.throwOrReturn();
  }

  Future<void> _cancelOrder() async {
    final currentState = state;
    if (currentState is! _Loaded || isClosed) return;

    final orderId = currentState.order.id;
    final result = await _orderRepository.cancelOrder(orderId);
    result.throwOrReturn();
  }

  Future<void> openMap(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
