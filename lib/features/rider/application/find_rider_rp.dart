import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/home/domain/entities/rider_data.dart';

sealed class FindRiderState {
  const FindRiderState();
}

final class FindRiderInitialState extends FindRiderState {
  const FindRiderInitialState({this.nearLocation});

  final Address? nearLocation;
}

final class FindingRiderState extends FindRiderState {
  const FindingRiderState();
}

final class RiderNotFoundState extends FindRiderState {
  const RiderNotFoundState({required this.error});
  final AppError? error;
}

final class RiderFoundState extends FindRiderState {
  const RiderFoundState({required this.rider, required this.eta});
  final RiderData rider;
  final String eta;
}

final class ContactingRiderState extends FindRiderState {
  const ContactingRiderState(this.rider);
  final RiderData rider;
}

final class RiderContactedState extends FindRiderState {
  const RiderContactedState(this.rider);
  final RiderData rider;
}

class FindRiderNotifier extends AutoDisposeNotifier<FindRiderState> {
  @override
  FindRiderState build() => const FindRiderInitialState();

  void setLocation(Address address) {
    state = FindRiderInitialState(nearLocation: address);
  }

  Future findRider() async {
    state = const FindingRiderState();
    await Future.delayed(const Duration(seconds: 2));
    const rider = RiderData(
      name: "Abdul Kareem",
      rating: 4.7,
      id: '',
      phone: '',
      imageUrl: ''
    );
    state = const RiderFoundState(eta: '40 min', rider: rider);
  }

  Future contactRider() async {
    state = ContactingRiderState((state as RiderFoundState).rider);
    await Future.delayed(const Duration(seconds: 2));

    state = RiderContactedState((state as ContactingRiderState).rider);
  }
}

final findRiderProvider = NotifierProvider.autoDispose(FindRiderNotifier.new);
