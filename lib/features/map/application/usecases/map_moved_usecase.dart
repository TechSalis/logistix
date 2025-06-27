import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/core/entities/usecase.dart';
import 'package:logistix/features/location_picker/application/location_picker_rp.dart';

class MapMovedUsecase extends Usecase {
  final Coordinates newCoordinates;
  final LocationPickerNotifier provider;
  final Address? address;

  MapMovedUsecase({
    required this.newCoordinates,
    required this.provider,
    required this.address,
  });

  @override
  FutureOr call() {
    if (address?.coordinates == null) {
      provider.getAddress(newCoordinates);
    } else if (_distBtw(newCoordinates, address!.coordinates!) > 500) {
      provider.getAddress(newCoordinates);
    }
  }

  double _distBtw(Coordinates from, Coordinates to) {
    final distance = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
    return distance;
  }
}
