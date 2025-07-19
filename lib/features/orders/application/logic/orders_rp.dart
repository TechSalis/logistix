import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/core/utils/page.dart';
import 'package:logistix/features/order_now/entities/order_request_data.dart';
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

  OrderTabData copyWith({Iterable<Order>? orders, PageData? page}) {
    return OrderTabData(orders: orders ?? this.orders, page: page ?? this.page);
  }
}

final class OrdersState {
  final Map<OrderFilter, OrderTabData> data;
  const OrdersState({required this.data});

  factory OrdersState.initial() => const OrdersState(
    data: {
      OrdersState.onGoing: OrderTabData(orders: [], page: pageOne),
      OrdersState.all: OrderTabData(orders: [], page: pageOne),
    },
  );

  OrdersState copyWith({Map<OrderFilter, OrderTabData>? data}) {
    return OrdersState(data: data ?? this.data);
  }

  static const onGoing = OrderFilter(
    statuses: [OrderStatus.pending, OrderStatus.accepted, OrderStatus.onTheWay],
  );
  static const all = OrderFilter();

  static const pageOne = PageData(index: 0, size: 10, isLast: false);
}

class OrdersNotifier extends AutoDisposeAsyncNotifier<OrdersState> {
  @override
  OrdersState build() {
    Future.microtask(() => getOrdersFor(OrdersState.onGoing));
    return OrdersState.initial();
  }

  Future getOrdersFor(OrderFilter filter, [bool refresh = false]) async {
    state = const AsyncValue.loading();

    final response = await ref
        .watch(_ordersRepoProvider)
        .getMyOrders(
          refresh ? OrdersState.pageOne : state.requireValue.data[filter]!.page,
          filter,
        );

    response.fold((l) => state = AsyncValue.error(l, StackTrace.current), (r) {
      final data = state.requireValue.data;
      return state = AsyncValue.data(
        state.requireValue.copyWith(
          data: {
            ...data,
            if (refresh)
              filter: OrderTabData(orders: r, page: OrdersState.pageOne)
            else
              filter: OrderTabData(
                orders: [...data[filter]!.orders, ...r],
                page: data[filter]!.page.next(
                  isLast: r.length < data[filter]!.page.size,
                ),
              ),
          },
        ),
      );
    });
  }

  void addLocalOrder(int refNumber, OrderRequestData requestData) {
    state = AsyncData(
      state.requireValue.copyWith(
        data: {
          ...state.requireValue.data,
          OrdersState.onGoing: state.requireValue.data[OrdersState.onGoing]!
              .copyWith(
                orders: [
                  Order(
                    refNumber: refNumber,
                    orderStatus: OrderStatus.pending,
                    orderType: requestData.orderType,
                    description: requestData.description,
                    pickup: requestData.pickup,
                    dropoff: requestData.dropoff,
                    price: null,
                    rider: null,
                  ),
                  ...state.requireValue.data[OrdersState.onGoing]!.orders,
                ],
              ),
        },
      ),
    );
  }
}

final ordersProvider =
    AsyncNotifierProvider.autoDispose<OrdersNotifier, OrdersState>(
      OrdersNotifier.new,
    );
