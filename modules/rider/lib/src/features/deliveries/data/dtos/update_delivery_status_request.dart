class UpdateDeliveryStatusRequest {
  const UpdateDeliveryStatusRequest({
    required this.deliveryId,
    required this.status,
    this.sessionId,
    this.pin,
    this.proofImageUrl,
  });

  factory UpdateDeliveryStatusRequest.fromJson(Map<String, dynamic> json) {
    return UpdateDeliveryStatusRequest(
      deliveryId: json['deliveryId'] as String,
      status: json['status'] as String,
      sessionId: json['sessionId'] as String?,
      pin: json['pin'] as String?,
      proofImageUrl: json['proofImageUrl'] as String?,
    );
  }

  final String deliveryId;
  final String status;
  final String? sessionId;
  final String? pin;
  final String? proofImageUrl;

  Map<String, dynamic> toJson() {
    return {
      'deliveryId': deliveryId,
      'status': status,
      if (sessionId != null) 'sessionId': sessionId,
      if (pin != null) 'pin': pin,
      if (proofImageUrl != null) 'proofImageUrl': proofImageUrl,
    };
  }
}
