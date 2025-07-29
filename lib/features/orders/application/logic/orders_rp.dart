import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/core/utils/page.dart';
import 'package:logistix/features/orders/domain/entities/base_order_data.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/orders/domain/repository/orders_repository.dart';
import 'package:logistix/features/orders/infrastructure/repository/orders_repo_impl.dart';

final ordersRepoProvider = Provider.autoDispose<OrdersRepository>((ref) {
  return OrdersRepositoryImpl(client: DioClient.instance);
});

final ordersProvider =
    AsyncNotifierProvider.autoDispose<OrdersNotifier, OrdersState>(
      OrdersNotifier.new,
    );

const _page = PageData.pageOne();

class OrderFilter {
  final Iterable<OrderType>? types;
  final Iterable<OrderStatus>? statuses;

  const OrderFilter({this.types, this.statuses});

  Map<String, dynamic> toJson() => {
    'order_types': types?.map((e) => e.name),
    'order_statuses': statuses?.map((e) => e.name),
  };
}

class OrderTabData {
  final Iterable<Order> orders;
  final PageData page;

  const OrderTabData({required this.orders, required this.page});
  const OrderTabData.initial() : orders = const [], page = _page;

  OrderTabData copyWith({Iterable<Order>? orders, PageData? page}) {
    return OrderTabData(orders: orders ?? this.orders, page: page ?? this.page);
  }
}

final class OrdersState {
  const OrdersState({required this.data});
  factory OrdersState.initial() => const OrdersState(data: {});

  final Map<OrderFilter, OrderTabData> data;

  OrdersState copyWith({Map<OrderFilter, OrderTabData>? data}) {
    return OrdersState(data: data ?? this.data);
  }

  OrderTabData? get(OrderFilter filter) => data[filter];

  OrderTabData _getNewIfAbsent(OrderFilter filter) =>
      data[filter] ?? const OrderTabData.initial();

  static const all = OrderFilter();
  static const ongoing = OrderFilter(
    statuses: [OrderStatus.pending, OrderStatus.accepted, OrderStatus.onTheWay],
  );
}

class OrdersNotifier extends AutoDisposeAsyncNotifier<OrdersState> {
  @override
  OrdersState build() => OrdersState.initial();

  Future fetchOrdersFor(OrderFilter filter, [bool refresh = false]) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(ordersRepoProvider)
          .getMyOrders(
            refresh ? _page : state.requireValue._getNewIfAbsent(filter).page,
            filter,
          );

      return response.fold((l) => throw l, (r) {
        final data = state.requireValue._getNewIfAbsent(filter);
        return state.requireValue.copyWith(
          data: {
            ...state.requireValue.data,
            if (refresh)
              filter: OrderTabData(
                orders: r,
                page: PageData(
                  index: _page.size,
                  size: _page.size,
                  isLast: r.length < _page.size,
                ),
              )
            else
              filter: OrderTabData(
                orders: [...data.orders, ...r],
                page: data.page.next(isLast: r.length < _page.size),
              ),
          },
        );
      });
    });
  }

  void addLocalOrder(Order order) {
    state = AsyncData(
      state.requireValue.copyWith(
        data: Map.from(state.requireValue.data)..addEntries([
          _createLocalOrderMapEntry(OrdersState.ongoing, order),
          _createLocalOrderMapEntry(OrdersState.all, order),
        ]),
      ),
    );
  }

  MapEntry<OrderFilter, OrderTabData> _createLocalOrderMapEntry(
    OrderFilter filter,
    Order order,
  ) {
    final data = state.requireValue._getNewIfAbsent(filter);
    return MapEntry(filter, data.copyWith(orders: [order, ...data.orders]));
  }
}

final cancelOrderProvider =
    AsyncNotifierProvider.autoDispose<CancelOrderNotifier, void>(
      CancelOrderNotifier.new,
);

class CancelOrderNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future cancelOrder(Order order) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref
          .read(ordersRepoProvider)
          .cancelOrder(order.orderId);

      response.fold((l) => throw l, (_) {
        final state = ref.read(ordersProvider).requireValue;
        var ongoing = state._getNewIfAbsent(OrdersState.ongoing);
        ongoing = ongoing.copyWith(
          orders: ongoing.orders.toList()..remove(order),
        );

        return state.copyWith(
          data: Map.from(state.data)..addEntries([
            MapEntry(OrdersState.ongoing, ongoing),
            ref
                .read(ordersProvider.notifier)
                ._createLocalOrderMapEntry(
                  OrdersState.all,
                  order.copyWith(status: OrderStatus.cancelled),
                ),
          ]),
        );
      });
    });
  }
}
