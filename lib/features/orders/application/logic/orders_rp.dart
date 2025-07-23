import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/core/utils/page.dart';
import 'package:logistix/features/order_create/entities/order_request_data.dart';
import 'package:logistix/features/orders/domain/entities/base_order_data.dart';
import 'package:logistix/features/orders/domain/entities/create_order.dart';
import 'package:logistix/features/orders/domain/entities/order_responses.dart';
import 'package:logistix/features/orders/domain/repository/orders_repository.dart';
import 'package:logistix/features/orders/infrastructure/repository/orders_repo_impl.dart';

final _ordersRepoProvider = Provider.autoDispose<OrdersRepository>((ref) {
  return OrdersRepositoryImpl(client: DioClient.instance);
});

class OrderTabData {
  final Iterable<Order> orders;
  final PageData page;

  const OrderTabData({required this.orders, required this.page});

  const OrderTabData.initial()
    : orders = const [],
      page = const PageData.pageOne();

  OrderTabData copyWith({Iterable<Order>? orders, PageData? page}) {
    return OrderTabData(orders: orders ?? this.orders, page: page ?? this.page);
  }
}

final class OrdersState {
  final Map<OrderFilter, OrderTabData> data;

  const OrdersState({required this.data});
  factory OrdersState.initial() => const OrdersState(data: {});

  OrdersState copyWith({Map<OrderFilter, OrderTabData>? data}) {
    return OrdersState(data: data ?? this.data);
  }

  OrderTabData? get(OrderFilter filter) => data[filter];

  OrderTabData _getNewIfAbsent(OrderFilter filter) =>
      data[filter] ?? const OrderTabData.initial();

  static const all = OrderFilter();
  static const onGoing = OrderFilter(
    statuses: [OrderStatus.pending, OrderStatus.accepted, OrderStatus.onTheWay],
  );

  static const _size = 10;
}

class OrdersNotifier extends AutoDisposeAsyncNotifier<OrdersState> {
  @override
  OrdersState build() => OrdersState.initial();


  Future fetchOrdersFor(OrderFilter filter, [bool refresh = false]) async {
    state = const AsyncValue<OrdersState>.loading();
    
    state = await AsyncValue.guard(() async {
      final response = await ref
          .watch(_ordersRepoProvider)
          .getMyOrders(
            refresh
                ? const PageData.pageOne()
                : state.requireValue._getNewIfAbsent(filter).page,
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
                  index: 0,
                  size: OrdersState._size,
                  isLast: r.length < OrdersState._size,
                ),
              )
            else
              filter: OrderTabData(
                orders: [...data.orders, ...r],
                page: data.page.next(isLast: r.length < OrdersState._size),
              ),
          },
        );
      });
    });
  }

  Order addOrderFromRequest(int refNumber, OrderRequestData requestData) {
    final newOrder = Order(
      refNumber: refNumber,
      orderType: requestData.orderType,
      description: requestData.description,
      pickup: requestData.pickup,
      dropoff: requestData.dropoff,
      price: requestData.price,
      orderStatus: OrderStatus.pending,
      rider: null,
    );

    MapEntry<OrderFilter, OrderTabData> createLocalOrderMapEntry(
      OrderFilter filter,
    ) {
      final data = state.requireValue._getNewIfAbsent(filter);
      return MapEntry(
        filter,
        data.copyWith(orders: [newOrder, ...data.orders]),
      );
    }

    state = AsyncData(
      state.requireValue.copyWith(
        data: Map.from(state.requireValue.data)..addEntries([
          createLocalOrderMapEntry(OrdersState.onGoing),
          createLocalOrderMapEntry(OrdersState.all),
        ]),
      ),
    );
    return newOrder;
  }
}

final ordersProvider =
    AsyncNotifierProvider.autoDispose<OrdersNotifier, OrdersState>(
      OrdersNotifier.new,
    );
