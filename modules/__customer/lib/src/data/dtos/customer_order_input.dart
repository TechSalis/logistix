class CustomerOrderInput {
  const CustomerOrderInput({
    required this.pickupAddress,
    required this.dropOffAddress,
    required this.dropOffPhone,
    required this.description,
    this.dropOffPlaceId,
    this.pickupPlaceId,
    this.pickupPhone,
    this.companyId,
    this.scheduledAt,
  });

  factory CustomerOrderInput.fromJson(Map<String, dynamic> json) {
    return CustomerOrderInput(
      pickupAddress: json['pickupAddress'] as String,
      dropOffAddress: json['dropOffAddress'] as String,
      dropOffPhone: json['dropOffPhone'] as String,
      description: json['description'] as String,
      dropOffPlaceId: json['dropOffPlaceId'] as String?,
      pickupPlaceId: json['pickupPlaceId'] as String?,
      pickupPhone: json['pickupPhone'] as String?,
      companyId: json['companyId'] as String?,
      scheduledAt: json['scheduledAt'] as String?,
    );
  }

  final String pickupAddress;
  final String dropOffAddress;
  final String dropOffPhone;
  final String description;
  final String? dropOffPlaceId;
  final String? pickupPlaceId;
  final String? pickupPhone;
  final String? companyId;
  final String? scheduledAt;

  Map<String, dynamic> toJson() {
    return {
      'pickupAddress': pickupAddress,
      'dropOffAddress': dropOffAddress,
      'dropOffPhone': dropOffPhone,
      'description': description,
      if (dropOffPlaceId != null) 'dropOffPlaceId': dropOffPlaceId,
      if (pickupPlaceId != null) 'pickupPlaceId': pickupPlaceId,
      if (pickupPhone != null) 'pickupPhone': pickupPhone,
      if (companyId != null) 'companyId': companyId,
      if (scheduledAt != null) 'scheduledAt': scheduledAt,
    };
  }
}
