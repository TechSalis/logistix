import 'package:flutter/material.dart';
import 'package:logistix/features/location_core/domain/entities/coordinate.dart';

class CoordinateTween extends Tween<Coordinates> {
  CoordinateTween({required Coordinates begin, required Coordinates end})
    : super(begin: begin, end: end);

  @override
  Coordinates lerp(double t) => Coordinates(
    _lerpDouble(begin!.latitude, end!.latitude, t),
    _lerpDouble(begin!.longitude, end!.longitude, t),
  );

  double _lerpDouble(double a, double b, double t) => a + (b - a) * t;
}
