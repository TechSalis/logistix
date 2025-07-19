import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/theme/styling.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';

sealed class FindRiderState {
  const FindRiderState();
}

class FindRiderInitialState extends FindRiderState {
  final Address? location;
  const FindRiderInitialState([this.location]);
}

class FindRiderReturnedWith extends FindRiderState {
  final RiderData? rider;
  const FindRiderReturnedWith(this.rider);
}
class FindRiderContacted extends FindRiderState {
  final RiderData? rider;
  const FindRiderContacted(this.rider);
}

class FindRiderNotifier extends AutoDisposeAsyncNotifier<FindRiderState> {
  @override
  FindRiderState build() => const FindRiderInitialState();

  void setLocation(Address address) {
    state = AsyncData(FindRiderInitialState(address));
  }

  Future findRider() async {
    state = const AsyncLoading();
    await Future.delayed(duration_3s);
    const rider = RiderData(
      name: "Abdul Kareem",
      rating: 4.7,
      id: '',
      phone: '',
      imageUrl: '',
    );
    state = const AsyncData(FindRiderReturnedWith(rider));
  }
}

final findRiderProvider = AsyncNotifierProvider.autoDispose(
  FindRiderNotifier.new,
);
