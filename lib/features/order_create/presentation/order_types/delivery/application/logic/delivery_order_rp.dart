import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/core/usecases/pick_image.dart';
import 'package:logistix/features/order_create/entities/order_request_data.dart';
import 'package:logistix/features/order_create/domain/repository/create_order_repo.dart';
import 'package:logistix/features/order_create/infrastructure/repository/create_order_repo_impl.dart';

final _createOrderRepoProvider = Provider.autoDispose<CreateOrderRepo>((ref) {
  return CreateOrderRepoImpl(client: DioClient.instance);
});

final createOrderProvider = FutureProvider.family.autoDispose((
  ref,
  OrderRequestData arg,
) async {
  final res = await ref
      .watch(_createOrderRepoProvider)
      .createOrder(arg.toNewOrder());
  return res.fold((l) => throw l, (r) => AsyncData(r));
});

final deliveryOrderImagesProvider = NotifierProvider.autoDispose(
  DeliveryOrderImagesNotifier.new,
);

class DeliveryOrderImagesNotifier extends AutoDisposeNotifier<List<String>> {
  @override
  List<String> build() => [];

  Future pickImage() async {
    final file = await PickImageUsecase().call();
    if (file != null && !state.contains(file.path)) {
      state = List.from(state)..add(file.path);
    }
  }

  void removeImage(int index) => state = List.from(state)..removeAt(index);
}
