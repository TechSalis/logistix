import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/core/utils/page.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
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

const _orders = [
  Order(
    refNumber: '1',
    type: OrderType.food,
    pickUp: Address(
      'Burger Place. Hilltop',
      coordinates: Coordinates(6.52, 3.37),
    ),
    dropOff: Address(
      'Divine Mercy Lodge, Hilltop',
      coordinates: Coordinates(6.51, 3.36),
    ),
    description: 'Burger + fries + drink combo',
    status: OrderStatus.accepted,
    price: 2500,
    rider: RiderData(id: 'id', name: 'John Doe', phone: 'phone', imageUrl: ''),
  ),
  Order(
    refNumber: '2',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description:
        'Pick up cleaned suits at 34 Orungle Street, Opposite Kings Close. Ikeja',
    status: OrderStatus.cancelled,
    price: 1500,
    rider: RiderData(id: 'id', name: 'John Doe', phone: 'phone', imageUrl: ''),
  ),
  Order(
    refNumber: '20',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description:
        'Pick up cleaned suits at 34 Orungle Street, Opposite Kings Close. Ikeja',
    status: OrderStatus.cancelled,
    price: 15000,
  ),
  Order(
    refNumber: '3',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description: 'Pick up cleaned suits',
    status: OrderStatus.pending,
    price: 1500,
    rider: null,
  ),
  Order(
    refNumber: '4',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description:
        'Pick up Chicken Republic at 34 Orungle Street, Opposite Kings Close. Ikeja.\nRepublic at 34 Orungle Street, Opposite Kings Close. Ikeja',
    status: OrderStatus.delivered,
    price: 1500,
    rider: RiderData(id: 'id', name: 'John Doe', phone: 'phone', imageUrl: ''),
  ),
  Order(
    refNumber: '5',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description: 'Pick up cleaned suits',
    status: OrderStatus.onTheWay,
    price: 1500,
    rider: RiderData(id: 'id', name: 'John Doe', phone: 'phone', imageUrl: ''),
  ),
  Order(
    refNumber: '7',
    type: OrderType.errands,
    pickUp: Address('Chicken Republic', coordinates: Coordinates(6.53, 3.35)),
    dropOff: Address(
      '34 Orungle Street, Opposite Kings Close. Ikeja',
      coordinates: Coordinates(6.50, 3.34),
    ),
    description: 'Pick up cleaned suits',
    status: OrderStatus.cancelled,
    price: 1500,
    rider: null,
  ),
];
