import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/utils/debouncer.dart';
import 'package:logistix/core/utils/extensions/dio.dart';
import 'package:logistix/features/location_core/domain/entities/place.dart';
import 'package:logistix/features/location_core/infrastructure/repository/google_places_search_location_service.dart';
import 'package:logistix/features/location_core/domain/repository/search_location_service.dart';
import 'package:logistix/features/location_core/infrastructure/datasources/google_places_datasource.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';

final _placesApi = Provider.autoDispose<GooglePlacesDatasource>(
  (ref) => GooglePlacesDatasource(ref.autoDisposeDio()),
);

final searchLocationRepoProvider = Provider.autoDispose<SearchLocationService>(
  (ref) => GooglePlacesSearchLocationServiceImpl(
    ref.watch(_placesApi),
    ref.watch(locationServiceProvider),
  ),
);

class LocationSearchState extends Equatable {
  const LocationSearchState({this.addresses, this.place, this.input});

  final PlaceDetails? place;
  final List<Address>? addresses;
  final String? input;

  LocationSearchState copyWith({
    List<Address>? addresses,
    PlaceDetails? place,
    String? input,
  }) {
    return LocationSearchState(
      addresses: addresses ?? this.addresses,
      place: place ?? this.place,
      input: input ?? this.input,
    );
  }

  @override
  List<Object?> get props => [addresses, place, input];
}

class LocationSearchNotifier
    extends AutoDisposeAsyncNotifier<LocationSearchState> {
  final debouncer = Debouncer();

  @override
  Future<LocationSearchState> build() async {
    ref.onDispose(debouncer.cancel);
    return const LocationSearchState();
  }

  void onInput(String text) async {
    if (text.isEmpty) {
      state = const AsyncData(LocationSearchState());
    } else if (text.length > 2) {
      debouncer.debounce(
        duration: Durations.long2,
        onDebounce: () => _getAddress(text),
      );
    }
  }

  Future<void> _getAddress(String text) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.watch(searchLocationRepoProvider).search(text);
      return LocationSearchState(addresses: result, input: text);
    });
  }
}

final locationSearchProvider = AsyncNotifierProvider.autoDispose(
  LocationSearchNotifier.new,
);
