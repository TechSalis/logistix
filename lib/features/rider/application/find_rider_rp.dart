import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';

sealed class FindRiderState {
  const FindRiderState();
}

class FindRiderInitialState extends FindRiderState {
  const FindRiderInitialState();
}

class LocationSelected extends FindRiderState {
  final Address location;
  const LocationSelected(this.location);
}

class SearchingForRiders extends FindRiderState {
  const SearchingForRiders();
}

class RidersFound extends FindRiderState {
  final List<RiderData> riders;
  const RidersFound(this.riders);
}

class NoRidersFound extends FindRiderState {
  const NoRidersFound();
}

class FindRiderNotifier extends AutoDisposeNotifier<FindRiderState> {
  @override
  FindRiderState build() => const FindRiderInitialState();

  void setLocation(Address address) {
    state = LocationSelected(address);
  }

  Future findRider() async {
    state = const SearchingForRiders();
    await Future.delayed(const Duration(seconds: 2));
    const rider = RiderData(
      name: "Abdul Kareem",
      rating: 4.7,
      id: '',
      phone: '',
      imageUrl: '',
    );
    state = const RidersFound([rider]);
  }
}

final findRiderProvider = NotifierProvider.autoDispose(FindRiderNotifier.new);
