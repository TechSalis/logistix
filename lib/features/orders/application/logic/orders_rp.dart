import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/core/utils/page.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';
import 'package:logistix/features/orders/domain/entities/order_repo_entiries.dart';
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

  factory OrdersState.initial() => const OrdersState(data: {});

  OrdersState copyWith({Map<OrderFilter, OrderTabData>? data}) {
    return OrdersState(data: data ?? this.data);
  }

  static const onGoing = OrderFilter(
    statuses: [OrderStatus.pending, OrderStatus.accepted, OrderStatus.onTheWay],
  );
  static const history = OrderFilter(
    statuses: [OrderStatus.cancelled, OrderStatus.delivered],
  );
}

class OrdersNotifier extends AutoDisposeAsyncNotifier<OrdersState> {
  @override
  OrdersState build() => OrdersState.initial();

  Future getOngoing() => _getOrdersFor(OrdersState.onGoing);

  Future getAll() => _getOrdersFor(OrdersState.history);

  Future _getOrdersFor(OrderFilter filter) async {
    final oldValue = state.requireValue.data[filter];
    final page =
        oldValue?.page ?? const PageData(index: 0, size: 10, isLast: false);

    state = const AsyncValue.loading();

    final response = await ref
        .watch(_ordersRepoProvider)
        .getMyOrders(page, filter);

    response.fold((l) => state = AsyncValue.error(l, StackTrace.current), (r) {
      return state = AsyncValue.data(
        state.requireValue.copyWith(
          data: {
            ...state.requireValue.data,
            filter: OrderTabData(
              orders: r,
              page: page.next(isLast: r.length < page.size),
            ),
          },
        ),
      );
    });
  }
}

final ordersProvider =
    AsyncNotifierProvider.autoDispose<OrdersNotifier, OrdersState>(
      OrdersNotifier.new,
    );
