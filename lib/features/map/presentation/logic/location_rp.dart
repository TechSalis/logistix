import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/map/data/repository/geocoding_service_impl.dart';
import 'package:logistix/features/map/data/repository/location_service_impl.dart';
import 'package:logistix/features/map/domain/entities/address.dart';
import 'package:logistix/features/map/domain/entities/coordinate.dart';
import 'package:logistix/features/map/domain/repository/geocoding_service.dart';
import 'package:logistix/features/map/domain/repository/location_service.dart';

final _geocodingServiceProvider = Provider<GeocodingService>((ref) {
  return NativeGeocodingServiceImpl();
});

final _locationServiceProvider = Provider<LocationService>((ref) {
  return LocationServiceImpl();
});

// final getUserLocationProvider = Provider.family.autoDispose<void, Coordinate>((
//   ref,
//   coordinate,
// ) async {
//   final service = ref.read(_locationServiceProvider);
//   final address = await service.getCoordinates();
//   if (!ref.exists(selectedCoordinatesProvider)) {
//     ref.read(selectedCoordinatesProvider.notifier).state = address;
//   }
// });

// final getAddressProvider = Provider.family.autoDispose<void, Coordinate>((
//   ref,
//   coordinate,
// ) async {
//   final service = ref.read(_geocodingServiceProvider);
//   final address = await service.getAddress(coordinate);
//   ref.read(selectedAddressProvider.notifier).state = address;
// });

// final selectedAddressProvider = StateProvider<Address?>((ref) => null);

// final selectedCoordinatesProvider = StateProvider<Coordinate>((ref) {
//   return Coordinate(6.5244, 3.3792);
// });

class LocationPickerState extends Equatable {
  const LocationPickerState({this.address, this.coordinates});

  final Address? address;
  final Coordinates? coordinates;

  LocationPickerState copyWith({Address? address, Coordinates? coordinates}) {
    return LocationPickerState(
      address: address ?? this.address,
      coordinates: coordinates ?? this.coordinates,
    );
  }

  @override
  List<Object?> get props => [address, coordinates];
}

class LocationPickerNotifier extends AutoDisposeNotifier<LocationPickerState> {
  @override
  LocationPickerState build() => LocationPickerState();

  Future getAddress(Coordinates coordinates) async {
    final service = ref.read(_geocodingServiceProvider);
    final address = await service.getAddress(coordinates);

    state = state.copyWith(address: address, coordinates: coordinates);
  }

  Future getUserCoordinate() async {
    final service = ref.read(_locationServiceProvider);
    final coordinates = await service.getCoordinates();

    state = state.copyWith(coordinates: coordinates);

    // if (!ref.exists(selectedCoordinatesProvider)) {
    //   ref.read(selectedCoordinatesProvider.notifier).state = address;
    // }
  }
}

final locationPickerProvider = NotifierProvider.autoDispose(
  LocationPickerNotifier.new,
);
