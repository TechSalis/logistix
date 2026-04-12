import 'package:shared/src/data/models/rider_dto.dart';
import 'package:shared/src/domain/entities/order.dart';

class OrderDto {
  const OrderDto({
    required this.id,
    required this.dropOffAddress,
    required this.trackingNumber,
    required this.status,
    required this.createdAt,
    this.pickupAddress,
    this.pickupPlaceId,
    this.pickupLat,
    this.pickupLng,
    this.dropOffPlaceId,
    this.dropOffLat,
    this.dropOffLng,
    this.riderId,
    this.trackingCode,
    this.rider,
    this.companyId,
    this.assignedCompanyId,
    this.codAmount,
    this.description,
    this.createdBy,
    this.pickupPhone,
    this.dropOffPhone,
    this.deliveredAt,
    this.scheduledAt,
    this.updatedAt,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    return OrderDto(
      id: json['id'] as String,
      dropOffAddress: json['dropOffAddress'] as String,
      trackingNumber: json['trackingNumber'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      pickupAddress: json['pickupAddress'] as String?,
      pickupPlaceId: json['pickupPlaceId'] as String?,
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      dropOffPlaceId: json['dropOffPlaceId'] as String?,
      dropOffLat: (json['dropOffLat'] as num?)?.toDouble(),
      dropOffLng: (json['dropOffLng'] as num?)?.toDouble(),
      riderId: json['riderId'] as String?,
      trackingCode: json['trackingCode'] as String?,
      rider: json['rider'] != null
          ? RiderDto.fromJson(json['rider'] as Map<String, dynamic>)
          : null,
      companyId: json['companyId'] as String?,
      assignedCompanyId: json['assignedCompanyId'] as String?,
      codAmount: (json['codAmount'] as num?)?.toDouble(),
      description: json['description'] as String?,
      createdBy: json['createdBy'] as String?,
      pickupPhone: json['pickupPhone'] as String?,
      dropOffPhone: json['dropOffPhone'] as String?,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'] as String)
          : null,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  final String id;
  final String dropOffAddress;
  final String trackingNumber;
  final String status;
  final DateTime createdAt;
  final String? pickupAddress;
  final String? pickupPlaceId;
  final double? pickupLat;
  final double? pickupLng;
  final String? dropOffPlaceId;
  final double? dropOffLat;
  final double? dropOffLng;
  final String? riderId;
  final String? trackingCode;
  final RiderDto? rider;
  final String? companyId;
  final String? assignedCompanyId;
  final double? codAmount;
  final String? description;
  final String? createdBy;
  final String? pickupPhone;
  final String? dropOffPhone;
  final DateTime? deliveredAt;
  final DateTime? scheduledAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dropOffAddress': dropOffAddress,
      'trackingNumber': trackingNumber,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (pickupAddress != null) 'pickupAddress': pickupAddress,
      if (pickupPlaceId != null) 'pickupPlaceId': pickupPlaceId,
      if (pickupLat != null) 'pickupLat': pickupLat,
      if (pickupLng != null) 'pickupLng': pickupLng,
      if (dropOffPlaceId != null) 'dropOffPlaceId': dropOffPlaceId,
      if (dropOffLat != null) 'dropOffLat': dropOffLat,
      if (dropOffLng != null) 'dropOffLng': dropOffLng,
      if (riderId != null) 'riderId': riderId,
      if (trackingCode != null) 'trackingCode': trackingCode,
      if (rider != null) 'rider': rider!.toJson(),
      if (companyId != null) 'companyId': companyId,
      if (assignedCompanyId != null) 'assignedCompanyId': assignedCompanyId,
      if (codAmount != null) 'codAmount': codAmount,
      if (description != null) 'description': description,
      if (createdBy != null) 'createdBy': createdBy,
      if (pickupPhone != null) 'pickupPhone': pickupPhone,
      if (dropOffPhone != null) 'dropOffPhone': dropOffPhone,
      if (deliveredAt != null) 'deliveredAt': deliveredAt!.toIso8601String(),
      if (scheduledAt != null) 'scheduledAt': scheduledAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

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
