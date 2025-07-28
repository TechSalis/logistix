import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/usecases/pick_image.dart';
import 'package:logistix/core/utils/cache_image_to_url.dart';
import 'package:logistix/features/auth/presentation/utils/auth_network_image.dart';
import 'package:logistix/features/order_create/application/create_order_rp.dart';


final uploadImageRequestProvider = FutureProvider.family.autoDispose((
  ref,
  String path,
) async {
  final res = await ref.watch(createOrderRepoProvider).uploadImage(path);
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
          AppNetworkImage(url),
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
