import 'dart:async';

import 'package:logistix/core/usecases/usecase.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';
import 'package:logistix/features/location_core/domain/repository/location_service.dart';

class GetUserCoordinates extends Usecase<Coordinates> {
  final GeoLocationService _locationService;

  GetUserCoordinates({required GeoLocationService locationService})
    : _locationService = locationService;

  @override
  Future<Coordinates> call() => _locationService.getUserCoordinates();
}
