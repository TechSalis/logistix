import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/src/data/models/address_dto.dart';
import 'package:shared/src/domain/services/places_service.dart';

class AddressCubit extends Cubit<void> {
  AddressCubit(this._placesService) : super(null);

  final PlacesService _placesService;

  Future<List<AddressDto>> fetchAddresses(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final predictions = await _placesService.getPredictions(query);
    
    return predictions.map((p) {
      final fullAddress = [p.title, p.description]
          .where((e) => e != null && e.isNotEmpty)
          .join(', ');
      return AddressDto(address: fullAddress, placeId: p.placeId);
    }).toList();
  }
}
