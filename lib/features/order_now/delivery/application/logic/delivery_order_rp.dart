import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/usecases/pick_image.dart';

final class DeliveryRequestData extends Equatable {
  final String description, pickup, dropoff;
  final List<String> imagePaths;

  const DeliveryRequestData({
    required this.description,
    required this.pickup,
    required this.dropoff,
    this.imagePaths = const [],
  });

  @override
  List<Object?> get props => [description, pickup, dropoff];
}

final requestDeliveryProvider = FutureProvider.family.autoDispose((
  ref,
  DeliveryRequestData arg,
) async {
  return const AsyncValue.data(true);
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
