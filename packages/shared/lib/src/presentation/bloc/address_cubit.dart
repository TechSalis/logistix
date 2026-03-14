import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_places_autocomplete/google_places_autocomplete.dart';
import 'package:shared/src/data/models/address_dto.dart';

class AddressCubit extends Cubit<void> {
  AddressCubit() : super(null) {
    _places = GooglePlacesAutocomplete(
      predictionsListener: _onPredictions,
      countries: ['ng'],
      onError: _onError,
    );
    _initTask = _initPlaces();
  }

  late final GooglePlacesAutocomplete _places;
  late final Future<void> _initTask;

  bool _isInitialized = false;
  Completer<List<AddressDto>>? _completer;

  Future<void> _initPlaces() async {
    await _places.initialize();
    _isInitialized = true;
  }

  void _onPredictions(List<Prediction> predictions) {
    final addresses = predictions.map((p) {
      final fullAddress = [?p.title, ?p.description].join(', ');
      return AddressDto(address: fullAddress);
    }).toList();

    _completer?.complete(addresses);
    _completer = null;
  }

  void _onError(PlacesException error) {
    _completer?.completeError('Failed to fetch addresses');
    _completer = null;
  }

  Future<List<AddressDto>> fetchAddresses(String query) async {
    if (query.isEmpty) {
      return [];
    }

    // Cancel / complete previous request if still pending
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete([]);
    }

    _completer = Completer<List<AddressDto>>();

    // Await initialization before making a request
    if (!_isInitialized) {
      await _initTask;
    }

    _places.getPredictions(query);

    try {
      return await _completer!.future.timeout(const Duration(seconds: 5));
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> close() {
    _places.dispose();
    return super.close();
  }
}
