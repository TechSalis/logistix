import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

class CustomerAddressCubit extends Cubit<void> {
  CustomerAddressCubit(this._placesService) : super(null);

  final PlacesService _placesService;

  Future<List<AddressDto>> fetchAddressesWithType(
    String filter,
    List<String> types,
  ) async {
    if (filter.isEmpty) return [];
    try {
      final predictions =
          await _placesService.getPredictionsWithType(filter, types);
      return predictions
          .map(
            (p) => AddressDto(
              address: p.description ?? p.title ?? '',
              placeId: p.placeId,
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}
