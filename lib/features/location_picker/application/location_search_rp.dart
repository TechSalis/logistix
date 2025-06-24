import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/utils/debouncer.dart';
import 'package:logistix/core/utils/extensions/widget_ref.dart';
import 'package:logistix/features/location/domain/entities/place.dart';
import 'package:logistix/features/location/infrastructure/repository/google_places_search_location_service.dart';
import 'package:logistix/features/location/domain/repository/search_location_service.dart';
import 'package:logistix/features/location/infrastructure/datasources/google_places_datasource.dart';
import 'package:logistix/features/location/domain/entities/address.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';

final placesApi = Provider.autoDispose<GooglePlacesDatasource>(
  (ref) => GooglePlacesDatasource(ref.autoDisposeDio()),
);

final _searchLocationProvider = Provider.autoDispose<SearchLocationService>(
  (ref) => GooglePlacesSearchLocationServiceImpl(
    ref.watch(placesApi),
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
    extends AutoDisposeStreamNotifier<LocationSearchState> {
  final debouncer = Debouncer();

  @override
  Stream<LocationSearchState> build() {
    ref.onDispose(debouncer.cancel);
    return const Stream.empty();
  }

  void onInput(String text) async {
    if (text.length > 2) {
      debouncer.debounce(
        duration: Durations.medium3,
        onDebounce: () async {
          final result = await ref.watch(_searchLocationProvider).search(text);
          state = AsyncValue.data(
            LocationSearchState(addresses: result, input: text),
          );
        },
      );
    }
  }

  Future<void> getPlaceData(Address address) async {
    final place = await ref.watch(_searchLocationProvider).place(address);
    state = AsyncData(state.requireValue.copyWith(place: place));
  }
}

final locationSearchProvider = StreamNotifierProvider.autoDispose(
  LocationSearchNotifier.new,
);
