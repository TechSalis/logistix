import 'package:flutter/foundation.dart';

@immutable
class AddressDto {
  const AddressDto({required this.address, this.placeId});

  factory AddressDto.fromJson(Map<String, dynamic> json) {
    return AddressDto(
      address: json['address'] as String,
      placeId: json['placeId'] as String?,
    );
  }

  final String address;
  final String? placeId;

  AddressDto copyWith({
    String? address,
    String? placeId,
  }) {
    return AddressDto(
      address: address ?? this.address,
      placeId: placeId ?? this.placeId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      if (placeId != null) 'placeId': placeId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressDto &&
          runtimeType == other.runtimeType &&
          address == other.address &&
          placeId == other.placeId;

  @override
  int get hashCode => address.hashCode ^ placeId.hashCode;
}
