import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/infrastructure/repository/location_service_impl.dart';
import 'package:logistix/features/location_core/domain/repository/location_service.dart';
import 'package:logistix/features/map/application/usecases/get_user_address.dart';

final locationServiceProvider = Provider.autoDispose<GeoLocationService>(
  (ref) => LocalGeoLocationServiceImpl(),
);

class UserLocationNotifier extends AutoDisposeNotifier<Address?> {
  StreamSubscription? _getUserCoordinatesStream;

  @override
  Address? build() => null;

  Future<void> getUserCoordinates() async {
    final coordinates =
        await ref.read(locationServiceProvider).getUserCoordinates();
    state = (state ?? Address.empty()).copyWith(coordinates: coordinates);
  }

  Future<Address?> getUserAddress() async {
    final address = await GetUserAddress(ref: ref).call();
    if (address != null) state = address;
    return address;
  }

  void trackUserCoordinates() {
    _getUserCoordinatesStream?.cancel();
    _getUserCoordinatesStream = ref
        .watch(locationServiceProvider)
        .getUserCoordinatesStream()
        .listen((coordinates) {
          state = (state ?? Address.empty()).copyWith(coordinates: coordinates);
        });
    ref.onDispose(() => _getUserCoordinatesStream?.cancel());
  }
}

final locationProvider =
    NotifierProvider.autoDispose<UserLocationNotifier, Address?>(
      UserLocationNotifier.new,
    );
