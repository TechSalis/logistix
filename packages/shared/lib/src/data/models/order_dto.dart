
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/data/models/rider_dto.dart';
import 'package:shared/src/domain/entities/order.dart';

part 'order_dto.freezed.dart';
part 'order_dto.g.dart';

@freezed
class OrderDto with _$OrderDto {
  const factory OrderDto({
    required String id,
    required String dropOffAddress,
    required String trackingNumber,
    required String status,
    required DateTime createdAt,
    String? pickupAddress,
    String? pickupPlaceId,
    double? pickupLat,
    double? pickupLng,
    String? dropOffPlaceId,
    double? dropOffLat,
    double? dropOffLng,
    String? riderId,
    RiderDto? rider,
    double? codAmount,
    String? description,
    String? pickupPhone,
    String? dropOffPhone,
    DateTime? deliveredAt,
    DateTime? updatedAt,
  }) = _OrderDto;

  const OrderDto._();

  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDtoFromJson(json);

  Order toEntity() => Order(
    id: id,
    riderId: riderId,
    rider: rider?.toEntity(),
    pickupAddress: pickupAddress,
    pickupPlaceId: pickupPlaceId,
    pickupLat: pickupLat,
    pickupLng: pickupLng,
    dropOffAddress: dropOffAddress,
    dropOffPlaceId: dropOffPlaceId,
    dropOffLat: dropOffLat,
    dropOffLng: dropOffLng,
    codAmount: codAmount,
    description: description,
    pickupPhone: pickupPhone,
    dropOffPhone: dropOffPhone,
    trackingNumber: trackingNumber,
    status: OrderStatusX.fromString(status),
    deliveredAt: deliveredAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
