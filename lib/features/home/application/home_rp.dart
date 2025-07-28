import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/utils/page.dart';
import 'package:logistix/features/orders/application/logic/orders_rp.dart';
import 'package:logistix/features/orders/domain/entities/order.dart';

class HomeState extends Equatable {
  const HomeState({this.orderPreview});

  final Order? orderPreview;

  HomeState copyWith({Order? orderPreview}) {
    return HomeState(orderPreview: orderPreview ?? this.orderPreview);
  }

  @override
  List<Object?> get props => [orderPreview];
}

class HomeNotifier extends AsyncNotifier<HomeState> {
  HomeNotifier();

  @override
  HomeState build() => const HomeState();

  Future fetchOrderPreview() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await ref
          .watch(ordersRepoProvider)
          .getMyOrders(const PageData(index: 0, size: 1), null);

      return response.fold(
        (l) => throw l,
        (r) => HomeState(orderPreview: r.first),
      );
    });
  }

  void updateOrderPreview(Order orderPreview) {
    state = AsyncData(state.requireValue.copyWith(orderPreview: orderPreview));
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeState>(
  HomeNotifier.new,
);
