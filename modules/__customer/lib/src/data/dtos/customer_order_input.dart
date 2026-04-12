class CustomerOrderInput {
  const CustomerOrderInput({
    required this.dropOffAddress,
    required this.dropOffPhone,
    required this.description,
    this.dropOffPlaceId,
    this.pickupAddress,
    this.pickupPlaceId,
    this.pickupPhone,
    this.companyId,
  });

  factory CustomerOrderInput.fromJson(Map<String, dynamic> json) {
    return CustomerOrderInput(
      dropOffAddress: json['dropOffAddress'] as String,
      dropOffPhone: json['dropOffPhone'] as String,
      description: json['description'] as String,
      dropOffPlaceId: json['dropOffPlaceId'] as String?,
      pickupAddress: json['pickupAddress'] as String?,
      pickupPlaceId: json['pickupPlaceId'] as String?,
      pickupPhone: json['pickupPhone'] as String?,
      companyId: json['companyId'] as String?,
    );
  }

  final String dropOffAddress;
  final String dropOffPhone;
  final String description;
  final String? dropOffPlaceId;
  final String? pickupAddress;
  final String? pickupPlaceId;
  final String? pickupPhone;
  final String? companyId;

  Map<String, dynamic> toJson() {
    return {
      'dropOffAddress': dropOffAddress,
      'dropOffPhone': dropOffPhone,
      'description': description,
      if (dropOffPlaceId != null) 'dropOffPlaceId': dropOffPlaceId,
      if (pickupAddress != null) 'pickupAddress': pickupAddress,
      if (pickupPlaceId != null) 'pickupPlaceId': pickupPlaceId,
      if (pickupPhone != null) 'pickupPhone': pickupPhone,
      if (companyId != null) 'companyId': companyId,
    };
  }
}
