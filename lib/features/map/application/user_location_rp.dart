import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/location_picker/application/location_picker_rp.dart';
import 'package:logistix/features/location_core/infrastructure/repository/location_service_impl.dart';
import 'package:logistix/features/location_core/domain/repository/location_service.dart';
import 'package:logistix/features/map/application/usecases/get_user_coordinates.dart';

final locationServiceProvider = Provider.autoDispose<GeoLocationService>(
  (ref) => LocalGeoLocationServiceImpl(),
);

class UserLocationNotifier extends AutoDisposeNotifier<Address?> {
  late final GetUserCoordinates _getUserCoordinatesUsecase;
  StreamSubscription? _getUserCoordinatesStream;

  @override
  Address? build() {
    _getUserCoordinatesUsecase = GetUserCoordinates(
      locationService: ref.read(locationServiceProvider),
    );
    return null;
  }

  Future<Coordinates> getUserCoordinates() async {
    final coordinates = await _getUserCoordinatesUsecase();
    state = (state ?? Address.empty()).copyWith(coordinates: coordinates);
    return coordinates;
  }

  Future<Address?> getUserAddress() async {
    final coordinates = await _getUserCoordinatesUsecase();
    final address = await ref.watch(
      addressFromCoordinatesProvider(coordinates).future,
    );
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
    ref.onDispose(() {
      _getUserCoordinatesStream?.cancel();
    });
  }
}

final locationProvider =
    NotifierProvider.autoDispose<UserLocationNotifier, Address?>(
      UserLocationNotifier.new,
    );
