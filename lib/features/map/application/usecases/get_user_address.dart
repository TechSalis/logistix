import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/core/usecases/usecase.dart';
import 'package:logistix/features/location_core/domain/entities/address.dart';
import 'package:logistix/features/location_picker/application/location_picker_rp.dart';
import 'package:logistix/features/map/application/user_location_rp.dart';

class GetUserAddress extends Usecase<Address?> {
  final Ref ref;
  GetUserAddress({required this.ref});

  @override
  Future<Address?> call() async {
    final coordinates =
        await ref.read(locationServiceProvider).getUserCoordinates();
    return ref.read(addressFromCoordinatesProvider(coordinates).future);
  }
}
