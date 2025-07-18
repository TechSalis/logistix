import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/extensions/dio.dart';
import 'package:logistix/features/location_core/infrastructure/repository/google_map_geocoding_service_impl.dart';
import 'package:logistix/features/location_core/infrastructure/repository/local_geocoding_service_impl.dart';
import 'package:logistix/features/location_core/infrastructure/datasources/google_maps_datasource.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/location_core/domain/repository/geocoding_service.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';
import 'package:logistix/features/permission/application/permission_rp.dart';
import 'package:logistix/features/permission/presentation/widgets/permission_dialog.dart';

// Dependency Injection

final _mapsApi = Provider.autoDispose<GoogleMapsDatasource>(
  (ref) => GoogleMapsDatasource(ref.autoDisposeDio()),
);

final _localGeocodingProvider = Provider.autoDispose<GeocodingService>((ref) {
  return LocalGeocodingServiceImpl();
});

final _remoteGeocodingProvider = Provider.autoDispose<GeocodingService>((ref) {
  return GoogleGeocodingServiceImpl(ref.watch(_mapsApi));
});

final addressFromCoordinatesProvider = FutureProvider.autoDispose
    .family<Address?, Coordinates>((ref, Coordinates arg) async {
      Address? address;
      try {
        // throw PlatformException(code: 'code');
        address = await ref.watch(_localGeocodingProvider).getAddress(arg);
      } on PlatformException {
        address = await ref.watch(_remoteGeocodingProvider).getAddress(arg);
      }
      return address;
    });

// State Manager
final locationPickerProvider = AsyncNotifierProvider.autoDispose(
  LocationPickerNotifier.new,
);

class LocationPickerNotifier
    extends AutoDisposeAsyncNotifier<LocationPickerState> {
  late final PermissionNotifier _permissionProvider;
  late final UserLocationNotifier _locationProvider;

  @override
  LocationPickerState build() {
    _permissionProvider = ref.read(
      permissionProvider(PermissionData.location).notifier,
    );
    _locationProvider = ref.read(locationProvider.notifier);
    return LocationPickerState.initial();
  }

  Future<void> setCoordinates(
    Coordinates coordinates, {
    double? minDistanceDeltaFromCurrentCoordinates = 500,
  }) async {
    if (state.value?.address?.coordinates == null) {
      _getAddress(coordinates);
    } else {
      final distance = Geolocator.distanceBetween(
        coordinates.latitude,
        coordinates.longitude,
        state.value!.address!.coordinates!.latitude,
        state.value!.address!.coordinates!.longitude,
      );
      if (minDistanceDeltaFromCurrentCoordinates == null ||
          distance > minDistanceDeltaFromCurrentCoordinates) {
        _getAddress(coordinates);
      }
    }
  }

  Future<void> _getAddress(Coordinates coordinates) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final address = await ref.watch(
        addressFromCoordinatesProvider(coordinates).future,
      );
      return state.value!.copyWith(address: address);
    });
  }

  void setAddress(Address address) {
    state = AsyncData(state.value!.copyWith(address: address));
  }

  Future<void> getUserCoordinates() async {
    if (!await _permissionProvider.request()) return;
    setCoordinates(
      await _locationProvider.getUserCoordinates(),
      minDistanceDeltaFromCurrentCoordinates: null,
    );
  }
}

// UI State
class LocationPickerState extends Equatable {
  const LocationPickerState({required this.address});
  final Address? address;

  factory LocationPickerState.initial() =>
      const LocationPickerState(address: null);


  LocationPickerState copyWith({Address? address, AppError? error}) {
    return LocationPickerState(address: address ?? this.address);
  }

  @override
  List<Object?> get props => [address];
}
