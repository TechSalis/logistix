import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/core/usecases/pick_image.dart';
import 'package:logistix/core/utils/cache_image_to_url.dart';
import 'package:logistix/features/auth/application/utils/auth_network_image.dart';
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

final uploadImageRequestProvider = FutureProvider.family.autoDispose((
  ref,
  String path,
) async {
  final res = await ref.watch(_createOrderRepoProvider).uploadImage(path);
  return res.fold((l) => throw l, (r) => r);
});

final imagesUploadProvider = AsyncNotifierProvider.autoDispose(() {
  return ImagesUploadNotifier(
    maxImages: 4,
    onUploadImage: (path, ref) {
      return ref.watch(uploadImageRequestProvider(path).future);
    },
  );
});

class ImagesUploadNotifier
    extends AutoDisposeAsyncNotifier<Map<String, String?>> {
  final int maxImages;
  final Future<String> Function(String path, Ref ref) onUploadImage;

  ImagesUploadNotifier({required this.maxImages, required this.onUploadImage});

  @override
  Map<String, String> build() => {};

  Future<void> uploadImage() async {
    final file = await PickImageUsecase().call();

    if (file != null && !state.requireValue.containsKey(file.path)) {
      state = AsyncData(Map.from(state.requireValue)..[file.path] = null);

      state = await AsyncValue.guard<Map<String, String?>>(() async {
        final url = await onUploadImage(file.path, ref);

        await cacheImageFromBytes(
          await file.readAsBytes(),
          NetworkImageWithAuth(url),
        );

        return Map.from(state.requireValue)..[file.path] = url;
      });
      if (state.hasError) {
        state = AsyncData(Map.from(state.requireValue)..remove(file.path));
      }
    }
  }

  bool isUploading(String path) => state.requireValue[path] == null;

  void removeImage(int index) {
    final newMap = Map<String, String>.from(state.requireValue)
      ..remove(state.requireValue.keys.elementAt(index));
    state = AsyncData(newMap);
  }
}
