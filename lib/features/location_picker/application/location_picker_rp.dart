import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/utils/app_error.dart';
import 'package:logistix/core/utils/extensions/dio.dart';
import 'package:logistix/features/location_core/infrastructure/repository/google_map_geocoding_service_impl.dart';
import 'package:logistix/features/location_core/infrastructure/repository/local_geocoding_service_impl.dart';
import 'package:logistix/features/location_core/infrastructure/datasources/google_maps_datasource.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/location_core/domain/repository/geocoding_service.dart';
import 'package:logistix/features/location_picker/application/location_search_rp.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';
import 'package:logistix/features/map/presentation/controllers/map_controller.dart';

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

final addressFromCoordinatesProvider = FutureProvider.autoDispose.family((
  ref,
  Coordinates arg,
) async {
  try {
    // throw PlatformException(code: 'code');
    return await ref.watch(_localGeocodingProvider).getAddress(arg);
  } on PlatformException {
    return await ref.watch(_remoteGeocodingProvider).getAddress(arg);
  }
});

// State Manager
final locationPickerProvider = AsyncNotifierProvider.autoDispose(
  LocationPickerNotifier.new,
);

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

class LocationPickerNotifier
    extends AutoDisposeAsyncNotifier<LocationPickerState> {
  final searchController = TextEditingController();
  MyMapController? map;

  @override
  LocationPickerState build() {
    ref.onDispose(searchController.dispose);
    return LocationPickerState.initial();
  }

  void setMap(MyMapController map) => this.map = map;

  Future pickMyLocation() async {
    final address = await ref.read(locationProvider.notifier).getUserAddress();
    if (address != null) _updateAddress(address);
  }

  Future pickAddress(Address address) async {
    assert(map != null, 'You need to set the map first. Use setMap()');
    final place = await ref.watch(searchLocationRepoProvider).place(address);
    _updateAddress(place.address);
  }

  // void setAddress(Address address) {
  //   state = AsyncData(state.value!.copyWith(address: address));
  // }
  Future pickCurrentCoordinates() async {
    assert(map != null, 'You need to set the map first. Use setMap()');
    final address = await ref.watch(
      addressFromCoordinatesProvider(map!.getCoordinates()).future,
    );
    _updateAddress(address!);
  }

  void _updateAddress(Address address) {
    map!.animateTo(address.coordinates!);
    searchController.text = address.name;
    state = AsyncData(state.requireValue.copyWith(address: address));
  }

  void clearInput() {
    state = AsyncData(LocationPickerState.initial());
    searchController.clear();
  }
}
