import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/extensions/widget_ref.dart';
import 'package:logistix/features/location/infrastructure/repository/google_map_geocoding_service_impl.dart';
import 'package:logistix/features/location/infrastructure/repository/local_geocoding_service_impl.dart';
import 'package:logistix/features/location/infrastructure/datasources/google_maps_datasource.dart';
import 'package:logistix/features/location/domain/entities/address.dart';
import 'package:logistix/features/location/domain/entities/coordinate.dart';
import 'package:logistix/features/location/domain/repository/geocoding_service.dart';

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
        // throw PlatformException(code: 'code');
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
    ref.watch(mapsApi);
    return LocationPickerState.initial();
  }

  Future<void> getAddress(Coordinates coordinates) async {
    state = const AsyncLoading();
    try {
      final Address? address = await ref.watch(
        addressFromCoordinatesProvider(coordinates).future,
      );
      state = AsyncData(state.value!.copyWith(address: address));
    } on AppError catch (e, s) {
      state = AsyncError(state.value!.copyWith(error: e), s);
    } catch (e, s) {
      state = AsyncError(
        state.value!.copyWith(error: AppError(error: e.toString())),
        s,
      );
    }
  }

  void setAddress(Address address) {
    state = AsyncData(state.value!.copyWith(address: address));
  }
}

// UI State
class LocationPickerState extends Equatable {
  const LocationPickerState({required this.address, this.error});

  factory LocationPickerState.initial() => const LocationPickerState(address: null);

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
