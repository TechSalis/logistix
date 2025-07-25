import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/services/dio_service.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/rider/domain/repository/rider_repo.dart';
import 'package:logistix/features/rider/infrastructure/repository/rider_repo_impl.dart';

final riderRepoProvider = Provider.autoDispose<RiderRepo>(
  (ref) => RiderRepoImpl(client: DioClient.instance),
);

sealed class FindRiderState {
  const FindRiderState([this.location]);
  final Coordinates? location;
}

class FindRiderInitialState extends FindRiderState {
  const FindRiderInitialState([super.location]);
}

class FindRiderReturnedWith extends FindRiderState {
  final RiderData? rider;
  const FindRiderReturnedWith(this.rider, [super.location]);
}

class FindRiderContacted extends FindRiderState {
  final RiderData rider;
  const FindRiderContacted(this.rider);
}

class FindRiderNotifier extends AutoDisposeAsyncNotifier<FindRiderState> {
  @override
  FindRiderState build() => const FindRiderInitialState();

  void setLocation(Coordinates coordinates) {
    state = AsyncData(FindRiderInitialState(coordinates));
  }

  Future findRider([Coordinates? coordinates]) async {
    if (coordinates != null) setLocation(coordinates);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await ref
          .read(riderRepoProvider)
          .findRiders(state.requireValue.location!);

      return res.fold(
        (l) => throw l,
        (r) => FindRiderReturnedWith(r.firstOrNull, state.value?.location),
      );
    });
  }
}

final findRiderProvider = AsyncNotifierProvider.autoDispose(
  FindRiderNotifier.new,
);
