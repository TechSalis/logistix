
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/features/order_create/domain/repository/create_order_repo.dart';
import 'package:logistix/features/order_create/entities/order_request_data.dart';
import 'package:logistix/features/order_create/infrastructure/repository/create_order_repo_impl.dart';

final createOrderRepoProvider = Provider.autoDispose<CreateOrderRepo>((ref) {
  return CreateOrderRepoImpl(client: DioClient.instance);
});

final createOrderProvider = FutureProvider.family.autoDispose((
  ref,
  OrderRequestData arg,
) async {
  final res = await ref
      .watch(createOrderRepoProvider)
      .createOrder(arg.toCreateOrder());

  return res.fold((l) => throw l, (r) => r);
});