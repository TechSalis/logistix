import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/extensions/widget_ref.dart';
import 'package:logistix/features/map/data/datasources/google_maps_datasource.dart';
import 'package:logistix/features/map/data/repository/google_map_geocoding_service_impl.dart';
import 'package:logistix/features/map/data/repository/local_geocoding_service_impl.dart';
import 'package:logistix/core/domain/entities/address.dart';
import 'package:logistix/core/domain/entities/coordinate.dart';
import 'package:logistix/features/map/domain/repository/geocoding_service.dart';

// Dependency Injection

final mapsApi = Provider.autoDispose<GoogleMapsDatasource>(
  (ref) => GoogleMapsDatasource(ref.autoDisposeDio()),
);


final _localGeocodingProvider = Provider.autoDispose<GeocodingService>((ref) {
  return LocalGeocodingServiceImpl();
});

final _remoteGeocodingProvider = Provider.autoDispose<GeocodingService>((ref) {
  return GoogleGeocodingServiceImpl(ref.watch(mapsApi));
});

final addressFromCoordinatesProvider = FutureProvider.family
    .autoDispose<Address?, Coordinates>((ref, Coordinates arg) async {
      Address? address;
      try {
        address = await ref.watch(_localGeocodingProvider).getAddress(arg);
      } on PlatformException {
        address = await ref.watch(_remoteGeocodingProvider).getAddress(arg);
      }
      return address;
    });



// State Manager
final locationPickerProvider = AutoDisposeAsyncNotifierProvider(
  LocationPickerNotifier.new,
);

class LocationPickerNotifier
    extends AutoDisposeAsyncNotifier<LocationPickerState> {
  @override
  LocationPickerState build() {
    return LocationPickerState.initial();
  }

  double _getDistanceBetween(Coordinates from, Coordinates to) {
    final distance = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
    return distance;
  }

  Future<void> getAddress(Coordinates coordinates) async {
    try {
      state = AsyncLoading();
      final Address? address = await ref.watch(
        addressFromCoordinatesProvider(coordinates).future,
      );
      state = AsyncData(state.value!.copyWith(address: address));
    } on AppError catch (e, s) {
      state = AsyncError(state.value!.copyWith(error: e), s);
    } catch (e, s) {
      state = AsyncError(state.value!.copyWith(error: AppError()), s);
    }
  }

  void setAddress(Address address) {
    state = AsyncData(state.value!.copyWith(address: address));
  }

  void onMapMoved(Coordinates newCoordinates) {
    if (state.requireValue.address?.coordinates == null) {
      getAddress(newCoordinates);
    } else if (_getDistanceBetween(
          newCoordinates,
          state.requireValue.address!.coordinates!,
        ) >
        500) {
      getAddress(newCoordinates);
    }
  }
}

// UI State
class LocationPickerState extends Equatable {
  const LocationPickerState({required this.address, this.error});

  factory LocationPickerState.initial() {
    return LocationPickerState(address: null);
  }

  final Address? address;
  final AppError? error;

  LocationPickerState copyWith({Address? address, AppError? error}) {
    return LocationPickerState(
      address: address ?? this.address,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [address, error];
}
