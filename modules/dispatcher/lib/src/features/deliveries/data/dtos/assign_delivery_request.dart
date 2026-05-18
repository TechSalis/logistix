class AssignDeliveryRequest {
  const AssignDeliveryRequest({
    required this.deliveryId,
    required this.riderId,
    this.sessionId,
  });

  factory AssignDeliveryRequest.fromJson(Map<String, dynamic> json) {
    return AssignDeliveryRequest(
      deliveryId: json['deliveryId'] as String,
      riderId: json['riderId'] as String,
      sessionId: json['sessionId'] as String?,
    );
  }

  final String deliveryId;
  final String riderId;
  final String? sessionId;

  Map<String, dynamic> toJson() {
    return {
      'deliveryId': deliveryId,
      'riderId': riderId,
      if (sessionId != null) 'sessionId': sessionId,
    };
  }
}
