import 'package:shared/shared.dart';

class OrderCreateInput {
  const OrderCreateInput({
    required this.dropOffAddress,
    this.dropOffPlaceId,
    this.pickupAddress,
    this.pickupPlaceId,
    this.description,
    this.codAmount,
    this.pickupPhone,
    this.dropOffPhone,
    this.companyId,
    this.assignedCompanyId,
    this.riderId,
    this.scheduledAt,
    this.rider,
  });

  factory OrderCreateInput.fromJson(Map<String, dynamic> json) {
    return OrderCreateInput(
      dropOffAddress: json['dropOffAddress'] as String,
      dropOffPlaceId: json['dropOffPlaceId'] as String?,
      pickupAddress: json['pickupAddress'] as String?,
      pickupPlaceId: json['pickupPlaceId'] as String?,
      description: json['description'] as String?,
      codAmount: (json['codAmount'] as num?)?.toDouble(),
      pickupPhone: json['pickupPhone'] as String?,
      dropOffPhone: json['dropOffPhone'] as String?,
      companyId: json['companyId'] as String?,
      assignedCompanyId: json['assignedCompanyId'] as String?,
      riderId: json['riderId'] as String?,
      scheduledAt: json['scheduledAt'] != null 
          ? DateTime.parse(json['scheduledAt'] as String) 
          : null,
    );
  }

  final String dropOffAddress;
  final String? dropOffPlaceId;
  final String? pickupAddress;
  final String? pickupPlaceId;
  final String? description;
  final double? codAmount;
  final String? pickupPhone;
  final String? dropOffPhone;
  final String? companyId;
  final String? assignedCompanyId;
  final String? riderId;
  final DateTime? scheduledAt;
  final Rider? rider;

  Map<String, dynamic> toJson() {
    return {
      'dropOffAddress': dropOffAddress,
      'dropOffPlaceId': dropOffPlaceId,
      'pickupAddress': pickupAddress,
      'pickupPlaceId': pickupPlaceId,
      'description': description,
      'codAmount': codAmount,
      'pickupPhone': pickupPhone,
      'dropOffPhone': dropOffPhone,
      // companyId is usually handled at repository level or hidden in DTO
      'assignedCompanyId': assignedCompanyId,
      'riderId': riderId,
      'scheduledAt': scheduledAt?.toIso8601String(),
    };
  }

  OrderCreateInput copyWith({
    String? dropOffAddress,
    String? dropOffPlaceId,
    String? pickupAddress,
    String? pickupPlaceId,
    String? description,
    double? codAmount,
    String? pickupPhone,
    String? dropOffPhone,
    String? companyId,
    String? assignedCompanyId,
    String? riderId,
    DateTime? scheduledAt,
    Rider? rider,
  }) {
    return OrderCreateInput(
      dropOffAddress: dropOffAddress ?? this.dropOffAddress,
      dropOffPlaceId: dropOffPlaceId ?? this.dropOffPlaceId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupPlaceId: pickupPlaceId ?? this.pickupPlaceId,
      description: description ?? this.description,
      codAmount: codAmount ?? this.codAmount,
      pickupPhone: pickupPhone ?? this.pickupPhone,
      dropOffPhone: dropOffPhone ?? this.dropOffPhone,
      companyId: companyId ?? this.companyId,
      assignedCompanyId: assignedCompanyId ?? this.assignedCompanyId,
      riderId: riderId ?? this.riderId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      rider: rider ?? this.rider,
    );
  }
}
