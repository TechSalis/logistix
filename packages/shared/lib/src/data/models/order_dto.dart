
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/src/data/models/rider_dto.dart';
import 'package:shared/src/domain/entities/order.dart';

part 'order_dto.freezed.dart';
part 'order_dto.g.dart';

@freezed
abstract class OrderDto with _$OrderDto {
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
    String? trackingCode,
    RiderDto? rider,
    String? companyId,
    String? assignedCompanyId,
    double? codAmount,
    String? description,
    String? createdBy,
    String? pickupPhone,
    String? dropOffPhone,
    DateTime? deliveredAt,
    DateTime? scheduledAt,
    DateTime? updatedAt,
  }) = _OrderDto;

  const OrderDto._();

  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDtoFromJson(json);

  Order toEntity() => Order(
    id: id,
    riderId: riderId,
    rider: rider?.toEntity(),
    companyId: companyId,
    assignedCompanyId: assignedCompanyId,
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
    createdBy: createdBy,
    pickupPhone: pickupPhone,
    dropOffPhone: dropOffPhone,
    trackingNumber: trackingNumber,
    trackingCode: trackingCode,
    status: OrderStatusX.fromString(status),
    deliveredAt: deliveredAt,
    scheduledAt: scheduledAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
