// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/data/models/rider_dto.dart';
import 'package:shared/src/domain/entities/order.dart';

part 'order_dto.freezed.dart';
part 'order_dto.g.dart';

@freezed
class OrderDto with _$OrderDto {
  const factory OrderDto({
    required String id,
    required String companyId,
    required String pickupAddress,
    required String trackingNumber,
    required String status,
    required DateTime createdAt,
    String? dropOffAddress,
    String? riderId,
    RiderDto? rider,
    String? items,
    double? codAmount,
    int? sequenceNumber,
    String? description,
    String? customerName,
    String? customerPhone,
    DateTime? deliveredAt,
    DateTime? updatedAt,
  }) = _OrderDto;

  const OrderDto._();

  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDtoFromJson(json);

  Order toEntity() => Order(
    id: id,
    companyId: companyId,
    riderId: riderId,
    rider: rider?.toEntity(),
    pickupAddress: pickupAddress,
    dropOffAddress: dropOffAddress,
    items: items,
    codAmount: codAmount,
    sequenceNumber: sequenceNumber,
    description: description,
    customerName: customerName,
    customerPhone: customerPhone,
    trackingNumber: trackingNumber,
    status: OrderStatusX.fromString(status),
    deliveredAt: deliveredAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
