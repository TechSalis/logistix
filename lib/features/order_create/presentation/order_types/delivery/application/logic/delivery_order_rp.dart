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
      
  return res.fold((l) => throw l, (r) => r);
});

final uploadImageProvider = FutureProvider.family.autoDispose((
  ref,
  String path,
) async {
  final res = await ref.watch(_createOrderRepoProvider).uploadImage(path);
  return res.fold((l) => throw l, (r) => r);
});

final orderImagesProvider = AsyncNotifierProvider.autoDispose(
  DeliveryOrderImagesNotifier.new,
);

class DeliveryOrderImagesNotifier
    extends AutoDisposeAsyncNotifier<List<String>> {
  static const maxImages = 4;

  @override
  List<String> build() => [];

  Future<void> pickImage() async {
    final file = await PickImageUsecase().call();
    if (file != null && !state.requireValue.contains(file.path)) {
      state = AsyncData(List.from(state.requireValue)..add(file.path));

      try {
        final url = await ref.watch(uploadImageProvider(file.path).future);

        state = AsyncData(
          List.from(state.requireValue)
            ..remove(file.path)
            ..add(url),
        );
      } catch (err, stack) {
        state = AsyncData(List.from(state.requireValue)..remove(file.path));
        state = AsyncValue.error(err, stack);
      }
    }
  }

  void removeImage(int index) {
    state = AsyncData(List.from(state.requireValue)..removeAt(index));
  }
}
