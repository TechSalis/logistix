import 'package:flutter/material.dart';

interface class DeliveryType {
  final String name;
  final String nickname;
  final ImageProvider image;

  const DeliveryType._({
    required this.name,
    required this.nickname,
    required this.image,
  });

  static const bike = DeliveryType._(
    name: 'Bike',
    nickname: 'Express',
    image: AssetImage(''),
  );

  static const bus = DeliveryType._(
    name: 'Bus/Van',
    nickname: 'Express',
    image: AssetImage(''),
  );

  static const car = DeliveryType._(
    name: 'Car',
    nickname: 'Express',
    image: AssetImage(''),
  );
}
