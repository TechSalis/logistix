import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/map/data/repository/location_service_impl.dart';
import 'package:logistix/core/domain/entities/address.dart';
import 'package:logistix/core/domain/entities/coordinate.dart';
import 'package:logistix/features/map/domain/repository/location_service.dart';
import 'package:logistix/features/map/presentation/logic/location_picker_rp.dart';
import 'package:logistix/features/permission/data/repository/location_settings_service_impl.dart';
import 'package:logistix/features/permission/domain/repository/settings_service.dart';

final _locationServiceProvider = Provider.autoDispose<GeoLocationService>(
  (ref) => LocalGeoLocationServiceImpl(),
);
final _locationSettingsProvider = Provider.autoDispose<SettingsService>(
  (ref) => LocationSettingsImpl(),
);

class UserLocationNotifier extends AutoDisposeNotifier<Address?> {
  @override
  Address? build() => null;

  Future<Coordinates> getUserCoordinates() async {
    final service = ref.read(_locationServiceProvider);
    final coordinates = await service.getUserCoordinates();
    state = (state ?? Address.empty()).copyWith(coordinates: coordinates);
    return state!.coordinates!;
  }

  Stream<Coordinates> trackUserCoordinates() {
    final data = ref.watch(_locationServiceProvider).getUserCoordinatesStream();
    return data..forEach((coordinates) {
      state = (state ?? Address.empty()).copyWith(coordinates: coordinates);
    });
  }

  Future<Address?> getUserAddress() async {
    final coordinates = await getUserCoordinates();
    state = await ref.watch(addressFromCoordinatesProvider(coordinates).future);
    return state;
  }

  void openSettings() => ref.read(_locationSettingsProvider).openSettings();
}

// State Manager
final locationProvider = AutoDisposeNotifierProvider(UserLocationNotifier.new);
