import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/location/domain/entities/address.dart';
import 'package:logistix/features/location/domain/entities/coordinate.dart';
import 'package:logistix/features/location_picker/application/location_picker_rp.dart';
import 'package:logistix/features/location/infrastructure/repository/location_service_impl.dart';
import 'package:logistix/features/location/domain/repository/location_service.dart';

final locationServiceProvider = Provider.autoDispose<GeoLocationService>(
  (ref) => LocalGeoLocationServiceImpl(),
);

class UserLocationNotifier extends AutoDisposeNotifier<Address?> {
  late final GeoLocationService _locationService;
  StreamSubscription? _getUserCoordinatesStream;

  @override
  Address? build() {
    ref.onDispose(() => _getUserCoordinatesStream?.cancel());
    _locationService = ref.watch(locationServiceProvider);
    return null;
  }

  Future<Coordinates> getUserCoordinates() async {
    final coordinates = await _locationService.getUserCoordinates();
    state = (state ?? Address.empty()).copyWith(coordinates: coordinates);
    return coordinates;
  }

  void trackUserCoordinates() {
    _getUserCoordinatesStream?.cancel();
    _getUserCoordinatesStream = _locationService
        .getUserCoordinatesStream()
        .listen((coordinates) {
          state = (state ?? Address.empty()).copyWith(coordinates: coordinates);
        });
  }

  Future<Address?> getUserAddress() async {
    final coordinates = await getUserCoordinates();
    final address = await ref.watch(
      addressFromCoordinatesProvider(coordinates).future,
    );
    state = address;
    return address;
  }
}

final locationProvider =
    NotifierProvider.autoDispose<UserLocationNotifier, Address?>(
      UserLocationNotifier.new,
    );
