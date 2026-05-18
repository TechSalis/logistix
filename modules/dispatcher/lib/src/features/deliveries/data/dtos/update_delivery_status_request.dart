class UpdateDeliveryStatusRequest {
  const UpdateDeliveryStatusRequest({
    required this.deliveryId,
    required this.status,
    this.sessionId,
  });

  factory UpdateDeliveryStatusRequest.fromJson(Map<String, dynamic> json) {
    return UpdateDeliveryStatusRequest(
      deliveryId: json['deliveryId'] as String,
      status: json['status'] as String,
      sessionId: json['sessionId'] as String?,
    );
  }

  final String deliveryId;
  final String status;
  final String? sessionId;

  Map<String, dynamic> toJson() {
    return {
      'deliveryId': deliveryId,
      'status': status,
      if (sessionId != null) 'sessionId': sessionId,
    };
  }
}
